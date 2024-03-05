#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import shutil, commands
import build_schema_node
from lxml import etree

def do_crawl_urls(crawl_urls=None, filelist=None):

   thingbomb = 0

   if ( filelist is None ):
      return []

   if ( crawl_urls is None ):
      crawl_urls = build_schema_node.create_crawl_urls()

   for item in filelist:

      thissynchro = 'indexed-no-sync'

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
                   contenttype='application/vxml-unnormalized',
                   addnodeto=crawl_url,
                   filename=item)

   return crawl_urls

def do_enqueues(dir):

   global alltime

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
            print "=============================, "
            crawl_urls = do_crawl_urls(crawl_urls, filelist)
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

   global alltime

   alltime = 0
   globaltime = 0

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 1

   collection_name2 = "idxall-1"
   collection_file = collection_name2 + '.xml'
   tname = 'indexer_allchars-1'

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
   yy.api_repository_update(xmlfile=collection_file)

   beginning = time.time()

   dir = "allchardata"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   filecount = do_enqueues(dir)

   xx.wait_for_idle(collection=collection_name2)

   endoftime = time.time()
   globaltime = endoftime - beginning

   adps =  float(filecount) / alltime 
   gdps =  float(filecount) / globaltime

   #resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   #indexedcount = yy.getTotalResults(resptree=resp)

   print tname, ":  ##################"


   #if ( filecount != indexedcount ):
   #   print tname, ":  total results and filecount differ"
   #   print tname, ":  total results = ", indexedcount
   #   print tname, ":  filecount     = ", filecount
   #else:
   #   print tname, ":  total results and filecount are correct at ", filecount
   #   fail = 0

   print tname, ":   Timings"
   print tname, ":      Accumulated time of enqueues, ", alltime
   print tname, ":         Docs per second, ", adps
   print tname, ":      first enqueue to all idle time, ", globaltime
   print tname, ":         Docs per second, ", gdps

   ##############################################################

   indexfile = collection_name2 + '.index'
   targetindexfile = 'querywork/' + collection_name2 + '.index'

   print tname, ":      Getting collection indices"
   xx.dump_indices(collectionname=collection_name2)
   shutil.move(indexfile, targetindexfile)
   print tname, ":      Done"

   print tname, ":      Converting indices and comparing to good data"
   fail, output = commands.getstatusoutput('./index_parser')
   print tname, ":      Done"
   if ( fail != 0 ):
      print tname, ":      Index data compare failed, indices differ"
   #xx.kill_all_services()

   if ( fail == 0 ):
      #xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
