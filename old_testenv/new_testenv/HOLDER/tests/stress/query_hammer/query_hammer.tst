#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import build_schema_node
from threading import Thread
from lxml import etree

class SimpleQuery ( Thread ):

   def __init__(self, collection=None, i=0):

      Thread.__init__(self)

      self.collection = collection
      self.threadnum = i

      self.xx = cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()

      return


   def run(self):

      query_list = [None, 'court', 'innocent', 'guilty OR innocent',
                    'guilty AND fine', 'NOT (guilty OR innocent)',
                    'NOT (guilty AND fine)']

      global gogo

      while (not gogo):
         continue

      total = singleton = 0

      for item in query_list:
         if ( item is None ):
            myq = ''
         else:
            myq = item

         beginning = time.time()
         resp = self.yy.api_qsearch(xx=self.xx, source=self.collection,
                                    query=myq)
         ending = time.time()

         singleton = ending - beginning
         total = total + singleton

         #
         #   This should be valid as there should be no dups on my file list.
         #
         indexedcount = self.yy.getTotalResults(resptree=resp)

         print self.threadnum, ':', indexedcount, ':', singleton, ':', total, ':', item

      return

def do_crawl_urls(crawl_urls=None, filelist=None, synchro=None):

   usesynchro = ['none', 'indexed', 'none', 'enqueued', 'indexed-no-sync',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', 'enqueued']

   thingbomb = 0

   if ( filelist is None ):
      return []

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()

   for item in filelist:

      if ( synchro == None ):
         whichone = thingbomb % 10
         thissynchro = usesynchro[whichone]
         thingbomb += 1
      else:
         thissynchro = synchro

      print item, thissynchro
      fname = os.path.basename(item)
      #fdir = os.path.dirname(item)
      #mydirpart = fdir.strip('/testenv/test_data/law/')
      print fname

      #url = ''.join(['http://junkurl/', mydirpart, '/', fname])
      url = ''.join(['file://', item])
      crawl_url = build_schema_node.create_crawl_url(url=url,
                  status='complete', enqueuetype='reenqueued',
                  synchronization=thissynchro, addnodeto=crawl_urls)
      crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                   contenttype='text/html', addnodeto=crawl_url,
                   filename=item)

   return crawl_urls

def do_enqueues(dir):

   global alltime

   usesynchro = [None, 'none', 'none', 'indexed-no-sync', 'enqueued',
                  'to-be-indexed', 'indexed-no-sync', 'to-be-crawled',
                  'indexed-no-sync', None]

   filecount = 0

   for path, dirs, files in os.walk(dir):

      filelist = []
      crawl_urls = None

      quitcounter = 0
      quitnum = len(files)

      lcnt = 103
      curcnt = 0

      for name in files:

         quitcounter += 1
         if ( quitcounter == quitnum ):
            curcnt = lcnt
         else:
            curcnt += 1

         fullpath = os.path.join(path, name)
         filelist.append(fullpath)
         filecount += 1

         if ( curcnt == lcnt ):
            which = filecount % 10
            synchro = usesynchro[which]
            print "=============================, ", synchro
            crawl_urls = do_crawl_urls(crawl_urls, filelist, synchro)
            print "============================="
            curcnt = 0
            lcnt -= 1
            beginning = time.time()
            resp = yy.api_sc_enqueue_xml(
                             collection=collection_name2,
                             subc='live',
                             crawl_nodes=etree.tostring(crawl_urls))
            endoftime = time.time()
            alltime = alltime + ( endoftime - beginning )
            #print etree.tostring(crawl_urls)
            filelist = []
            crawl_urls = None
            if ( lcnt == 0 ):
               lcnt = 103

      print "FILES ENQUEUED (interim):  ", filecount


   print "FILES ENQUEUED (final):  ", filecount

   return filecount


if __name__ == "__main__":

   global alltime, gogo

   alltime = 0
   globaltime = 0

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 1

   collection_name2 = "query_hammer"
   tname = "query_hammer"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  audit logs test 1"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name2
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name2)

   yy.api_sc_create(collection=collection_name2, based_on='default-push')

   beginning = time.time()

   dir = "/testenv/test_data/law/US"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   filecount = do_enqueues(dir)

   xx.wait_for_idle(collection=collection_name2)

   endoftime = time.time()
   globaltime = endoftime - beginning

   adps =  float(filecount) / alltime 
   gdps =  float(filecount) / globaltime

   countlist = [1, 2, 4, 8, 16, 32]

   for item in countlist:
      tlist = []
      i = 0
      print tname, "###################################################"
      print tname, ":  NUMBER OF QUERY THREADS, ", item 
      gogo = False
      while ( i < item ):
         doit = SimpleQuery(collection=collection_name2, i=i)
         tlist.append(doit)
         doit.start()
         i += 1
      gogo = True

      for item in tlist:
         item.join()
      print tname, "###################################################"

   print tname, ":  ##################"

   resp = yy.api_qsearch(xx=xx, source=collection_name2,
                         query='')
   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   if ( filecount != indexedcount ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  filecount     = ", filecount
   else:
      print tname, ":  total results and filecount are correct at ", filecount
      fail = 0

   print tname, ":   Timings"
   print tname, ":      Accumulated time of enqueues, ", alltime
   print tname, ":         Docs per second, ", adps
   print tname, ":      first enqueue to all idle time, ", globaltime
   print tname, ":         Docs per second, ", gdps

   ##############################################################

   #xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
