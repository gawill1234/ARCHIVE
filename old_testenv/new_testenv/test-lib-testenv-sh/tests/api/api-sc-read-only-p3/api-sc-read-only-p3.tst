#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
import random
from lxml import etree

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

      if ( filecount >= 500 ):
         break


   print "FILES ENQUEUED (final):  ", filecount

   return filecount

def thetest(yy=None, collection_name2=None):

   fail = 0
   tname = "api-sc-read-only-p3"

   g = random.Random(time.time())

   try:
      err=yy.api_sc_indexer_full_merge(collection=collection_name2, subc='live')
   except:
      print tname, ":  full merge error but continuing"

   time.sleep(1)

   #
   #   Rapidly shift read only back and forth between enabled and
   #   disabled.  The final state will be unknown, but it should not
   #   be stuck in pending.
   #
   i = 0
   while ( i <= 500 ):

      slp1 = g.randint(0, 2)
      slp2 = g.randint(0, 2)

      print tname, ":  read only enable/disable loop pass", i
      try: err = yy.api_sc_read_only(collection=collection_name2, mode='enable')
      except:
         print tname, ":  read only enable error but continuing"

      print tname, ":  read only enabled, sleep for", slp1
      time.sleep(slp1)

      try:
         err = yy.api_sc_read_only(collection=collection_name2, mode='disable')
      except:
         print tname, ":  read only disable error but continuing"

      print tname, ":  read only disabled, sleep for", slp2
      time.sleep(slp2)

      i += 1

   time.sleep(5)
   seefoo = yy.api_sc_read_only(collection=collection_name2, mode='status')
   crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                         tagname='read-only-state',
                                         attrname='mode')

   i = 0
   while ( (crostat == 'pending' ) and i < 10 ):
      time.sleep(1)
      seefoo = yy.api_sc_read_only(collection=collection_name2, mode='status')
      crostat = yy.getResultGenericTagValue(resptree=seefoo,
                                            tagname='read-only-state',
                                            attrname='mode')

      i += 1

   if ( crostat != 'pending' ):
      print tname, ":   Read only mode final state"
      print tname, ":   Read only mode status =", crostat
      if ( crostat == 'enabled' ):
         print tname, ":  attempting to disable read only mode (final)"
         try:
            err=yy.api_sc_read_only(collection=collection_name2, mode='disable')
            print tname, ":  read only disable (final) completed"
         except:
            print tname, ":  read only disable (final) error but continuing"
   else:
      print tname, ":   Read only mode appears stuck"
      print tname, ":   Read only mode status =", crostat
      fail += 1

   stattree = yy.api_sc_status(collection=collection_name2, subc='live')

   mrgflcnt1 = yy.getResultGenericTagCount(resptree=stattree,
                                           tagname='vse-index-file',
                                           attrname='fname')

   i = 0
   while ( mrgflcnt1 != 1 and i <= 10 ):
      time.sleep(1)
      mrgflcnt1 = yy.getResultGenericTagCount(resptree=stattree,
                                              tagname='vse-index-file',
                                              attrname='fname')
      i += 1

   if ( mrgflcnt1 > 1 ):
      print tname, ":  The merge failed after 10 seconds"
      fail += 1
   else:
      print tname, ":  The merge completed"

   xx.wait_for_idle(collection=collection_name2)

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

   collection_name2 = "scro-p3"
   tname = "api-sc-read-only-p3"

   ##############################################################
   #
   #   Set up work
   #
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Read only during a collection merge"

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

   fail = fail + thetest(yy, collection_name2)

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
