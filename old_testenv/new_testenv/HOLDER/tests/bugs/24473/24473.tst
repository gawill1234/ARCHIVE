#!/usr/bin/python

import os, sys, string, time
import build_schema_node
import cgi_interface, vapi_interface
from lxml import etree
import velocityAPI
from threading import Thread

class SimpleQuery( Thread ):

   def __init__(self, yy, xx, collection):

      Thread.__init__(self)

      self.yy = yy
      self.xx = xx
      self.collection = collection

      return

   def run(self):

      error = False

      qcount = 20
      ccount = 0

      while ( ccount < qcount ):
         self.yy.api_qsearch(xx=self.xx, source=self.collection,
                             query="", num=500)

         ccount += 1

      return


class EnqueueThread( Thread ):

   def __init__(self, collection, enqueue_node, whichpart):

      Thread.__init__(self)

      self.node = enqueue_node
      self.collection = collection
      self.part = whichpart

      return

   def run(self):

      error = False

      try:
         yy.api_sc_enqueue_xml(collection=self.collection, subc='live',
                           eonfail='true',
                           crawl_nodes=etree.tostring(self.node))
      except velocityAPI.VelocityAPIexception:
         print ">>>>>>>>>>>>>>> ENQUEUE ERROR IN", self.part
         ex_xml, ex_text = sys.exc_info()[1]
         print self.part, ", unexpected failure"
         print '%s:  %s' % (self.collection, ex_text)
         print "Enqueue failed"
         error = True

      return error



def dopartone(myvsekey, myurl, mycollection, 
              cname, item, amounttoread):

   mydata, size, start, readit = read_file_from(filename=item,
                                    frompt=0, readamt=amounttoread)

   newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                  url=myurl,
                                  forcevsekeynorm="yes",
                                  synchronization='enqueued')
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
   #print etree.tostring(newcrwlurl)

   return newcrwlurl

def doparttwo(myvsekey, myurl, mycollection, 
              cname, item, amounttoread, startread):


   mydata, size, start, readit = read_file_from(filename=item,
                                    frompt=startread,
                                    readamt=amounttoread)

   newcrwlurl = build_schema_node.create_crawl_url(status='complete',
                                  url=myurl,
                                  forcevsekeynorm="yes",
                                  synchronization='enqueued')
   newcrwldata = build_schema_node.create_crawl_data(
                       contenttype='application/vxml',
                       addnodeto=newcrwlurl, encoding='xml')
   newcont = build_schema_node.create_content(name=cname,
                               text=mydata, addto=myvsekey,
                               vseaddtonorm="vse-add-to-normalized",
                               addnodeto=newcrwldata)
   #print etree.tostring(newcrwlurl)

   return newcrwlurl


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
      for path, dirs, files in os.walk(directory):
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

def run_and_join3(list1, list2, list3):

   print "##########################################################"
   for item in list1:
      item.start()
   for item in list2:
      item.start()
   for item in list3:
      item.start()

   for item in list1:
      item.join()
   for item in list2:
      item.join()
   for item in list3:
      item.join()
   print "##########################################################"

   return

def run_and_join1(list1):

   print "##########################################################"
   for item in list1:
      item.start()

   for item in list1:
      item.join()
   print "##########################################################"

   return

def build_qobj(xx=None, yy=None, collection=None):

   qlist = []

   i = 0
   while ( i < 5 ):
      thing = SimpleQuery(yy, xx, collection)
      qlist.append(thing)
      i += 1

   return qlist


if __name__ == "__main__":

   #filename = "/testenv/test_data/law/US/320/320.US.338.27.41.html"
   dirlist = ['/testenv/test_data/law/US/525',
              '/testenv/test_data/law/US/3',
              '/testenv/test_data/law/US/267']

   #dirlist = ['/testenv/test_data/law/US/525']

   collection_name = '24473'
   tname = "24473"

   fail = 0

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   yy.api_sc_create(collection=collection_name, based_on='default-push')

   for docount in range(0, 10):

      fullcount = 0
      vsebase = 0

      for mydir in dirlist:
   
         print tname, ":  Workding with directory", mydir
   
         filelist = directory_file_list(mydir)
   
         print filelist
      
         maxcount = len(filelist)
         fullcount += maxcount
   
         print tname, ":  List has", maxcount, "files"
      
         fdict = build_file_data_dictionary(filelist)
      
         tlistA = []
         tlistB = []
         tlistC = []
         twit = maxcount - 1
         while ( twit >= 0 ):
            item = filelist[twit]
            url = 'file://' + item
      
            amounttoread = fdict[item][0] / 2
      
            mynode = dopartone('%s' % (vsebase + twit), url, collection_name, "main",
                              item, amounttoread)
            anitem = EnqueueThread(collection_name, mynode, "PARTONE/A")
            tlistA.append(anitem)
            anitem = EnqueueThread(collection_name, mynode, "PARTONE/B")
            tlistB.append(anitem)
            anitem = EnqueueThread(collection_name, mynode, "PARTONE/C")
            tlistC.append(anitem)
      
            print tname, ":  ---------"
            print tname, ":  URL used     =", url
            print tname, ":  vse-key used =", twit + vsebase
      
            fdict[item][1] = amounttoread
            fdict[item][2] = fdict[item][0] - amounttoread
            twit -= 1
      
         run_and_join3(tlistA, tlistB, tlistC)
      
         tlistA = []
         tlistB = []
         tlistC = []
         twit = 0
         while ( twit < maxcount ):
            item = filelist[twit]
            url = 'file://' + item + ".again"
      
            mynode = doparttwo('%s' % (vsebase + twit), url, collection_name, "added",
                              item, fdict[item][2], fdict[item][1])
            anitem = EnqueueThread(collection_name, mynode, "PARTTWO/A")
            tlistA.append(anitem)
            anitem = EnqueueThread(collection_name, mynode, "PARTTWO/B")
            tlistB.append(anitem)
            anitem = EnqueueThread(collection_name, mynode, "PARTTWO/C")
            tlistC.append(anitem)
      
            print tname, ":  ---------"
            print tname, ":  URL used     =", url
            print tname, ":  vse-key used =", twit + vsebase
      
            fdict[item][1] = fdict[item][0]
            fdict[item][2] = 0
            twit += 1
            
         run_and_join3(tlistA, tlistB, tlistC)
      
         qlist1 = build_qobj(xx=xx, yy=yy, collection=collection_name)
         qlist2 = build_qobj(xx=xx, yy=yy, collection=collection_name)
         qlist3 = build_qobj(xx=xx, yy=yy, collection=collection_name)
      
         run_and_join1(qlist1)
         run_and_join1(qlist2)
         run_and_join1(qlist3)
   
         vsebase += twit
   
   print tname, ":  Total files enqueued =", fullcount
         
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  Gather results and check them"

   resp = yy.api_qsearch(source=collection_name, filename="blah",
                         query="", num=200)
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
   efull_count = fullcount * 3
   bad_count = len(bdlist)

   econt_count = main_count + added_count + snip_count

   if ( bad_count != 0 ):
      print tname, ":   Standalone content found with no <document>"
      fail += 1

   if ( url_count != fullcount ):
      print tname, ":   Document count not as expected"
      fail += 1

   if ( main_count != fullcount ):
      print tname, ":   Main content not as expected"
      fail += 1

   if ( added_count != fullcount ):
      print tname, ":   Added content not as expected"
      fail += 1

   if ( snip_count != fullcount ):
      print tname, ":   Snippet content not as expected"
      fail += 1

   if ( econt_count != efull_count or
        full_count != efull_count ):
      print tname, ":   Content nodes not as expected"
      fail += 1

   print tname, ':  <document url="blah blah blah ..."> count'
   print tname, ":     Actual   =", url_count
   print tname, ":     Expected =", fullcount
   print tname, ':  <content name="main"> count'
   print tname, ":     Actual   =", main_count
   print tname, ":     Expected =", fullcount
   print tname, ':  <content name="added"> count'
   print tname, ":     Actual   =", added_count
   print tname, ":     Expected =", fullcount
   print tname, ':  <content name="snippet"> count'
   print tname, ":     Actual   =", snip_count
   print tname, ":     Expected =", fullcount

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
