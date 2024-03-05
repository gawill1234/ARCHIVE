#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
from lxml import etree
from threading import Thread

class SimpleQuery ( Thread ):

   def __init__(self, collection=None):

      Thread.__init__(self)

      self.collection = collection

      self.xx = cgi_interface.CGIINTERFACE()
      self.yy = vapi_interface.VAPIINTERFACE()

      return


   def run(self):

      global fail, done
      tname = "api-sc-read-only-p2"

      i = 0
      resp = self.yy.api_qsearch(xx=self.xx, source=self.collection,
                                    query='', num=10000)
      idxdcnt1 = yy.getTotalResults(resptree=resp)

      while ( i < 500 ):
         print tname, ":  Doing thread loop query"
         resp = self.yy.api_qsearch(xx=self.xx, source=self.collection,
                                    query='', num=10000)
         print tname, ":  Query complete"

         idxdcnt2 = yy.getTotalResults(resptree=resp)

         print tname, ":     results expected, ", idxdcnt1
         print tname, ":     results actual,   ", idxdcnt2


         if ( idxdcnt1 != idxdcnt2 ):
            fail += 1
            print tname, ":  query failed for read only"

         i += 1

         if ( done == 1 ):
            break

      done = 1

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

      if ( filecount >= 5000 ):
         break


   print "FILES ENQUEUED (final):  ", filecount

   return filecount

def thetest(yy=None, collection_name2=None, dobug=0):

   global fail, done

   done = 0
   fail = 0
   tname = "api-sc-read-only-p2"

   seefoo = yy.api_sc_read_only(collection=collection_name2,
                                mode='status')

   crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                         tagname='read-only-state',
                                         attrname='mode')

   print tname, ":  Read Only check value is, ", crostat
   if ( crostat == 'enabled' or crostat == 'pending' ):
      print tname, ":  Read Only enabled, disabling"
      err = yy.api_sc_read_only(collection=collection_name2,
                                mode='disable')
      time.sleep(5)

   doit = SimpleQuery(collection=collection_name2)
   doit.start()

   i = 0
   while ( i <= 250 ):
      try:
         err = yy.api_sc_read_only(collection=collection_name2, mode='enable')
      except:
         print tname, ":  read only enable error but continuing"

      crostat = 'disabled'

      j = 0
      while ( (crostat == 'disabled' or crostat == 'pending' ) and j < 5 ):
         seefoo = yy.api_sc_read_only(collection=collection_name2,
                                      mode='status')
         crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                               tagname='read-only-state',
                                               attrname='mode')

         time.sleep(1)
         j += 1

      if ( crostat != 'enabled' ):
         print tname, ":   Read only mode would not enable in 5 seconds"
         print tname, ":   Read only mode status =", crostat
         fail += 1
         done = 1
      else:
         print tname, ":  Read Only enabled in around", j

      time.sleep(2)

      try:
         err = yy.api_sc_read_only(collection=collection_name2,
                                   mode='disable')
      except:
         print tname, ":  read only disable error but continuing"

      if ( dobug == 0 ):
         while ( (crostat == 'enabled' or crostat == 'pending' ) and j < 5 ):
            seefoo = yy.api_sc_read_only(collection=collection_name2,
                                         mode='status')
            crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                                  tagname='read-only-state',
                                                  attrname='mode')

            time.sleep(1)
            j += 1

         if ( crostat != 'disabled' ):
            print tname, ":   Read only mode would not disable in 5 seconds"
            print tname, ":   Read only mode status =", crostat
            fail += 1
            done = 1
         else:
            print tname, ":  Read Only disabled in around", j
      else:
         time.sleep(2)
         print tname, ":  Read Only disabled"

      i += 1

      if ( done == 1 ):
         break

   done = 1

   print tname, ":   FAIL FINAL VALUE,", fail

   return fail


if __name__ == "__main__":

   global alltime

   alltime = 0
   globaltime = 0

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 0

   collection_name2 = "scro-p2"
   tname = "api-sc-read-only-p2"

   ##############################################################
   #
   #   Set up work
   #
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Read only during a large query"

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

   #
   #   Set up is complete.
   #
   #########################################################
   #
   #   Run the actual test
   #

   fail = fail + thetest(yy, collection_name2, dobug=1)

   #
   #   Test is complete.
   #
   #########################################################
   #
   #   Clean up and final verification
   #

   globaltime = endoftime - beginning

   adps =  float(filecount) / alltime 
   gdps =  float(filecount) / globaltime

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   print tname, ":  ##################"


   if ( filecount != indexedcount ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  filecount     = ", filecount
      fail += 1
   else:
      print tname, ":  total results and filecount are correct at ", filecount

   print tname, ":   Timings"
   print tname, ":      Accumulated time of enqueues, ", alltime
   print tname, ":         Docs per second, ", adps
   print tname, ":      first enqueue to all idle time, ", globaltime
   print tname, ":         Docs per second, ", gdps

   ##############################################################

   xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
