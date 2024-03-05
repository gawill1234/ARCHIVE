#!/usr/bin/python

import os, sys, string, time
import build_schema_node
import cgi_interface, vapi_interface
from lxml import etree
import velocityAPI

def get_file_size(filename=None):

   datasize = 0

   if ( filename is not None ):
      if (os.access(filename, os.R_OK) == 1 ):
         datasize = os.stat(filename).st_size

   return datasize


def read_file_from(filename=None, frompt=0, readamt=0):

   data = None
   datasize = 0

   if ( filename is not None ):
      if (os.access(filename, os.R_OK) == 1 ):
         datasize = get_file_size(filename)
         if ( datasize > frompt ):
            f = open(filename, "r")
            f.seek(frompt)
            data = f.read(readamt)
            f.close()
         else:
            frompt = 0

   return data, datasize, frompt, readamt

def directory_file_list(directory=None):

   filelist = []

   if ( directory is not None ):
      for item in directory:
         for path, dirs, files in os.walk(item):
            for name in files:
               fullpath = os.path.join(path, name)
               filelist.append(fullpath)

   return filelist

def build_file_data_dictionary(filelist=[]):

   file_dict = {}

   for item in filelist:
      datasize = get_file_size(item)
      file_dict[item] = [datasize, 0, datasize]

   return file_dict

if __name__ == "__main__":


   mydir = ['/testenv/test_data/law/US/525']

   fail = 0
   collection_name = 'no_doc_enqueue'
   tname = "no_doc_enqueue_1"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.is_testenv_mounted()

   print tname, "######################################"
   print tname, ":   Test no <document> enqueues of <content>"
   print tname, ":   This test enqueues content from files"
   print tname, ":   in two parts with no document node."
   print tname, ":   The document node is supplied at the"
   print tname, ":   end and is expected to be properly"
   print tname, ":   mated with the previously entered content"
   print tname, ":   based on the fact that each document is"
   print tname, ":   supplied an appropriate vse-key."

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   yy.api_sc_create(collection=collection_name, based_on='default-push')

   filelist = directory_file_list(mydir)

   maxcount = len(filelist)
   print tname, ":  List has", maxcount, "files"

   fdict = build_file_data_dictionary(filelist)

   print "##########################################################"
   print "##########################################################"
   #
   #   Print and comment ...
   print tname, ":  PART ONE:  Enqueue a bunch of content without"
   print tname, ":  the associated document nodes.  The correct vse-key"
   print tname, ":  for the completed doc is specified."
   #
   twit = maxcount - 1
   while ( twit >= 0 ):
      item = filelist[twit]
      url = 'file://' + item + '.top'

      amounttoread = fdict[item][0] / 2
      data, size, start, readit = read_file_from(filename=item,
                                       frompt=0, readamt=amounttoread)

      newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                     url=url,
                                     synchronization='enqueued')
      newcrwldata = build_schema_node.create_crawl_data(
                          contenttype='application/vxml',
                          addnodeto=newcrwlurl, encoding='xml')
      newcont = build_schema_node.create_content(name='main', text=data,
                                  addto= '%s' % twit,
                                  addnodeto=newcrwldata)
      #print etree.tostring(newcrwlurl)
      try:
         yy.api_sc_enqueue_xml(collection=collection_name, subc='live',
                           crawl_nodes=etree.tostring(newcrwlurl),
                           eonfail='true')
      except velocityAPI.VelocityAPIexception:
         print tname, ":  >>>>>>>>>>>>>>> ENQUEUE ERROR IN DOPARTONE"
         ex_xml, ex_text = sys.exc_info()[1]
         print tname, ":  DOPARTONE, unexpected failure"
         print tname, ": ", '%s:  %s' % (collection_name, ex_text)
         print tname, ":  Enqueue failed"

      print tname, ":  ---------"
      print tname, ":  URL used     =", url
      print tname, ":  vse-key used =", twit

      fdict[item][1] = readit
      fdict[item][2] = fdict[item][0] - readit
      twit -= 1

   print "##########################################################"
   print "##########################################################"

   print tname, ":  Content is not yet available check"
   resp = yy.api_qsearch(source=collection_name, filename="unavail",
                         query="", num=100)
   url_count = yy.getResultData(tagname='document', attrname='url',
                             ri='count', resptree=resp)

   if ( url_count != 0 ):
      print tname, ":     Content is available without a document node"
      fail += 1
   else:
      print tname, ":     Content is not available without a document node"
      print tname, ":     This is the expected result"

   print "##########################################################"
   print "##########################################################"
   #
   #   Print and comment ...
   print tname, ":  PART TWO:  Enqueue a bunch of content without"
   print tname, ":  the associated document nodes.  The correct vse-key"
   print tname, ":  for the completed doc is specified.  These are done"
   print tname, ":  in reverse order of above."
   #
   twit = 0
   while ( twit < maxcount ):
      item = filelist[twit]
      url = 'file://' + item + ".bottom"
#
      data, size, start, readit = read_file_from(filename=item,
                                       frompt=fdict[item][1],
                                       readamt=fdict[item][2])
#
      newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                     url=url,
                                     synchronization='enqueued')
      newcrwldata = build_schema_node.create_crawl_data(
                          contenttype='application/vxml',
                          addnodeto=newcrwlurl, encoding='xml')
      newcont = build_schema_node.create_content(name='added',
                                  text=data, addto= '%s' % twit,
                                  addnodeto=newcrwldata)
      #print etree.tostring(newcrwlurl)
      try:
         yy.api_sc_enqueue_xml(collection=collection_name, subc='live',
                           crawl_nodes=etree.tostring(newcrwlurl),
                           eonfail='true')
      except velocityAPI.VelocityAPIexception:
         ex_xml, ex_text = sys.exc_info()[1]
         print tname, ":  >>>>>>>>>>>>>>> ENQUEUE ERROR IN DOPARTTWO"
         print tname, ":  DOPARTTWO, unexpected failure"
         print tname, ": ", '%s:  %s' % (collection_name, ex_text)
         print tname, ":  Enqueue failed"
#
      print tname, ":  ---------"
      print tname, ":  URL used     =", url
      print tname, ":  vse-key used =", twit
#
      fdict[item][1] = fdict[item][0]
      fdict[item][2] = 0
      twit += 1
      
   print "##########################################################"
   print "##########################################################"

   print tname, ":  Content is not yet available check"
   resp = yy.api_qsearch(source=collection_name, filename="unavail",
                         query="", num=100)
   url_count = yy.getResultData(tagname='document', attrname='url',
                             ri='count', resptree=resp)

   if ( url_count != 0 ):
      print tname, ":     Content is available without a document node"
      fail += 1
   else:
      print tname, ":     Content is not available without a document node"
      print tname, ":     This is the expected result"

   print "##########################################################"
   print "##########################################################"
   #
   #   Print and comment ...
   print tname, ":  PART THREE:  Enqueue a bunch of documents without"
   print tname, ":  the associated content nodes.  The correct vse-key"
   print tname, ":  for the completed doc is specified.  These are done"
   print tname, ":  in reverse order of above."
   #
   twit = maxcount - 1
   while ( twit >= 0 ):
      item = filelist[twit]
      url = 'file://' + item

      newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                     url=url,
                                     synchronization='enqueued')
      newcrwldata = build_schema_node.create_crawl_data(
                          contenttype='application/vxml',
                          addnodeto=newcrwlurl, encoding='xml')
      newdoc = build_schema_node.create_document(
                                 vsekey='%s' % twit,
                                 addnodeto=newcrwldata)
      #print etree.tostring(newcrwlurl)
      try:
         yy.api_sc_enqueue_xml(collection=collection_name, subc='live',
                           crawl_nodes=etree.tostring(newcrwlurl),
                           eonfail='true')
      except velocityAPI.VelocityAPIexception:
         print tname, ":  >>>>>>>>>>>>>>> ENQUEUE ERROR IN DOPARTTHREE"
         ex_xml, ex_text = sys.exc_info()[1]
         print tname, ":  DOPARTTHREE, unexpected failure"
         print tname, ": ", '%s:  %s' % (collection_name, ex_text)
         print tname, ":  Enqueue failed"


      print tname, ":  ---------"
      print tname, ":  URL used     =", url
      print tname, ":  vse-key used =", twit

      fdict[item][1] = readit
      fdict[item][2] = fdict[item][0] - readit
      twit -= 1

   print "##########################################################"
   print "##########################################################"
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  Gather results and check them"

   resp = yy.api_qsearch(source=collection_name, filename="blah",
                         query="", num=100)
   main_count = yy.getResultData(tagname='content', attrname='name',
                             attrvalue='main', ri='count', resptree=resp)
   added_count = yy.getResultData(tagname='content', attrname='name',
                             attrvalue='added', ri='count', resptree=resp)
   snip_count = yy.getResultData(tagname='content', attrname='name',
                             attrvalue='snippet', ri='count', resptree=resp)
   url_count = yy.getResultData(tagname='document', attrname='url',
                             ri='count', resptree=resp)
   mlist = resp.xpath('//document/content/@name')
   bdlist = resp.xpath('//list/content')
   full_count = len(mlist)
   efull_count = maxcount * 3
   bad_count = len(bdlist)

   econt_count = main_count + added_count + snip_count

   if ( bad_count != 0 ):
      print tname, ":   Standalone content found with no <document>"
      fail += 1

   if ( url_count != maxcount ):
      print tname, ":   Document count not as expected"
      fail += 1

   if ( main_count != maxcount ):
      print tname, ":   Main content not as expected"
      fail += 1

   if ( added_count != maxcount ):
      print tname, ":   Added content not as expected"
      fail += 1

   if ( snip_count != maxcount ):
      print tname, ":   Snippet content not as expected"
      fail += 1

   if ( econt_count != efull_count or
        full_count != efull_count ):
      print tname, ":   Content nodes not as expected"
      fail += 1

   print tname, ':  <document url="blah blah blah ..."> count'
   print tname, ":     Actual   =", url_count
   print tname, ":     Expected =", maxcount
   print tname, ':  <content name="main"> count'
   print tname, ":     Actual   =", main_count
   print tname, ":     Expected =", maxcount
   print tname, ':  <content name="added"> count'
   print tname, ":     Actual   =", added_count
   print tname, ":     Expected =", maxcount
   print tname, ':  <content name="snippet"> count'
   print tname, ":     Actual   =", snip_count
   print tname, ":     Expected =", maxcount
   
   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
