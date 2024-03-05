#!/usr/bin/python

import os, sys, string, time, getopt
import build_schema_node
import cgi_interface, vapi_interface
import velocityAPI
from lxml import etree

def dopartone(myvsekey, myurl, mydata, mycollection, cname):

   error = False

   newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                  url=myurl,
                                  forcevsekeynorm="yes",
                                  synchronization='indexed')
   newcrwldata = build_schema_node.create_crawl_data(
                       contenttype='application/vxml',
                       addnodeto=newcrwlurl, encoding='xml')
   newdoc = build_schema_node.create_document(
                              vsekey=myvsekey,
                              vsekeynormalized="vse-key-normalized",
                              addnodeto=newcrwldata)
   newcont = build_schema_node.create_content(name=cname, text=mydata,
                               vseaddtonorm="vse-add-to-normalized",
                               addnodeto=newdoc)
   print etree.tostring(newcrwlurl)

   try:
      yy.api_sc_enqueue_xml(collection=mycollection, subc='live',
                        eonfail='true',
                        crawl_nodes=etree.tostring(newcrwlurl))
   except velocityAPI.VelocityAPIexception:
      print ">>>>>>>>>>>>>>> ENQUEUE ERROR IN DOPARTONE"
      ex_xml, ex_text = sys.exc_info()[1]
      print "DOPARTONE, unexpected failure"
      print '%s:  %s' % (collection_name, ex_text)
      print "Enqueue failed"
      error = True

   return error

def doparttwo(myvsekey, myurl, mydata, mycollection, cname):

   error = False

   newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                  url=myurl,
                                  forcevsekeynorm="yes",
                                  synchronization='indexed')
   newcrwldata = build_schema_node.create_crawl_data(
                       contenttype='application/vxml',
                       addnodeto=newcrwlurl, encoding='xml')
   newcont = build_schema_node.create_content(name=cname,
                               text=mydata, addto=myvsekey,
                               vseaddtonorm="vse-add-to-normalized",
                               addnodeto=newcrwldata)
   print etree.tostring(newcrwlurl)
   try:
      resp = yy.api_sc_enqueue_xml(collection=mycollection, subc='live',
                        eonfail='true',
                        crawl_nodes=etree.tostring(newcrwlurl))
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      success = ex_xml.get('name') == 'search-collection-enqueue'
      if not success:
         print ">>>>>>>>>>>>>>> ENQUEUE ERROR IN DOPARTTWO"
         print "DOPARTTWO, unexpected failure"
         print '%s:  %s' % (collection_name, ex_text)
         print "Enqueue failed"
      error = True


   return error

if __name__ == "__main__":

   opts, args = getopt.getopt(sys.argv[1:], "l", ["light"])

   collection_name = 'variable_url_collectionX'
   tname = "variable_url_name_no_lc"
   cfile = collection_name + '.xml'
   uselc = False
   maxcount = 1000

   for o, a in opts:
      if o in ("-l" "--light"):
         uselc = True  
         maxcount = 500
         tname = "variable_url_name_use_lc"

   print tname, ":   TEST PURPOSE"
   print tname, ":   Add content that has really long urls"
   print tname, ":   starting at 399 and increasing by 10"
   print tname, ":   until we get to 550"
   print tname, ":   many levels in the url (/ separators)"
   if ( uselc ):
      print tname, ":   light crawler IS being used"
   else:
      print tname, ":   light crawler IS NOT being used"

   fail = 0

   #
   #   REALLY long urls, this is the base at 399 with the http part included.
   #
   url = "this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/to/perform/abcdefghijklmonpqrstuvwxyz/0123456789/this/is/a/really/long/but/bogus/name/designed/to/make/things/look/a/little/wonky/while/not/really/doing/anything/to/the/function/of/action/which/i/am/attempting/toperf"

   fullurl = 'http://127.0.0.1:7205/' + url
   mylen = len(fullurl)

   #
   #   If we are not using the light crawler, bump up the start point
   #   for the url length.  Try to limit the number of iterations.
   #
   if ( not uselc ):
      while ( mylen < 875 ):
         url = url + '/ABCDEFGHI'
         fullurl = 'http://127.0.0.1:7205/' + url
         mylen = len(fullurl)

   data1 = "This is a test of the emergency broadcast system."
   data2 = "The quick brown fox jumps over the lazy dog."

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   mylen = len(fullurl)
   partlen = len(url)
   iteration = 1
   while ( mylen < maxcount ):
      print "#"
      print "#############################################################"
      print "#"
      print tname, ":   Iteration", iteration
      print tname, ":      Check that the collection in this test does"
      print tname, ":      not exist.  If it does, delete it and"
      print tname, ":      recreate it.  This assures that each"
      print tname, ":      iteration starts with a clean, empty"
      print tname, ":      collection."
      cex = xx.collection_exists(collection=collection_name)
      if ( cex == 1 ):
         xx.delete_collection(collection=collection_name)

      #
      #   Done this way to get rid of light crawler in an easy way.
      #
      yy.api_sc_create(collection=collection_name, based_on='default-push')
      if ( not uselc ):
         yy.api_repository_update(xmlfile=cfile)

#####################################################################

      print "#"
      print "#############################################################"
      print "#"

      print tname, ":   CASE 1"
      print tname, ":      Initial enqueue"
      print tname, ":      url len with 'http://127.0.0.1:7205/' is", mylen
      print tname, ":      url len without 'http://127.0.0.1:7205/' is", partlen
      print tname, ":      This is the first entry in a collection"
      print tname, ":      and should be queryable.  The query"
      print tname, ":      should yield 1 result."
      explist = [fullurl]
      error = dopartone("0", url, data1, collection_name, "main")
      if ( error ):
         print tname, ":  Initial enqueue to a collection failed"
         print tname, ":  Test Failed"
         sys.exit(1)
      xx.wait_for_idle(collection=collection_name)
      resp = yy.api_qsearch(source=collection_name, query="", filename="blah")
      try:
         urlcount = yy.getTotalResults(resptree=resp)
      except:
         urlcount = 0
      filename = yy.look_for_file(filename='blah')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
      ret = yy.check_list(explist, urllist)
      print tname, ":  urlcount", urlcount, ", expected 1"
      if ( ret != 0 or urlcount != 1 ):
         fail += 1
         print tname, ":  CASE FAILED"
      else:
         print tname, ":  CASE PASSED"

      print "#"
      print "#############################################################"
      print "#"

      print tname, ":   CASE 2"
      print tname, ":      Enqueue for add-to using same url as CASE 1"
      if ( uselc ):
         print tname, ":   For the light crawler:"
         print tname, ":      The expectation, based on feedback in bug 26100"
         print tname, ":      is that this enqueue will cause all data in this"
         print tname, ":      document to disappear.  It will be un-queryable."
         print tname, ":      I.e., a query will yield 0 documents."
         explist = []
         listcomp2 = [fullurl]
         expurlcount = 0
      else:
         print tname, ":   For the non-light crawler:"
         print tname, ":      The expectation, based on feedback in bug 26100"
         print tname, ":      is that this enqueue will cause an error"
         print tname, ":      resulting in no change to the document."
         print tname, ":      I.e., a query will yield 1 document."
         explist = [fullurl]
         listcomp2 = []
         expurlcount = 1

      error = doparttwo("0", url, data2, collection_name, "added")

      if ( uselc ):
         if ( error ):
            print tname, ":  Secondary enqueue to a collection failed for"
            print tname, ":  an enqueue to light crawler.  There should"
            print tname, ":  be no errors for this in light crawler mode."
            print tname, ":  Test Failed"
            sys.exit(1)

      xx.wait_for_idle(collection=collection_name)
      resp = yy.api_qsearch(source=collection_name, query="", 
                            filename="munchy")
      try:
         urlcount = yy.getTotalResults(resptree=resp)
      except:
         urlcount = 0
      filename = yy.look_for_file(filename='munchy')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)
      print tname, ":  Primary list check for case 2"
      ret = yy.check_list(explist, urllist)
      print tname, ":  Primary check completed"
      print tname, ":  Secondary list check for case 2"
      print tname, ":     You should see a 'lists do not match' message"
      ret2 = yy.check_list(listcomp2, urllist)
      print tname, ":  Secondary check completed"
      print tname, ":  urlcount", urlcount, ", expected", expurlcount
      if ( ret != 0 or urlcount != expurlcount ):
         fail += 1
         print tname, ":  CASE FAILED"
         if ( ret2 == 0 ):
            print tname, ":  Case failed because the url we expected to get overwritten was not"
            print tname, ":  ", urllist
            print tname, ":  ", listcomp2
            print tname, ":  url length is", mylen
            print tname, ":  Test Failed"
            sys.exit(1)
      else:
         print tname, ":  CASE PASSED"

      print "#"
      print "#############################################################"
      print "#"

      url = url + '/ABCDEFGHI'
      fullurl = 'http://127.0.0.1:7205/' + url
      mylen = len(fullurl)
      partlen = len(url)
      iteration += 1

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
