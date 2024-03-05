#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This test is identical to files-2loop except it uses the old
#   way fo creating and starting a collection and it runs in staging.
#
#   Test request from Stan in Bug 25854
#

import sys, time, cgi_interface, vapi_interface 
import shutil
from lxml import etree

def loop_on_status(yy=None, collection=None):

   if ( collection is None ):
      return "unknown"

   crlstat = None
   idxstat = None

   max_loop = 60
   current = 0
   while ( current < max_loop ):

      #
      #   If the status fails, the test fails.
      #
      try:
         mine = yy.api_sc_status(collection=collection, subc='staging')
      except:
         print tname, ":  Collection status get failed"
         print tname, ":  Test Failed"
         sys.exit(1)

      if ( mine is not None ):
         crlstat = mine.xpath('crawler-status/@service-status')
         idxstat = mine.xpath('vse-index-status/@service-status')
         print crlstat, idxstat
         if ( len(crlstat) >= 1 ) and ( len(idxstat) >= 1 ):
            if ( crlstat[0] == 'stopped' or idxstat[0] == 'stopped' ):
               time.sleep(1)
               current += 2
            else:
               current = 60
         else:
            time.sleep(1)
            current += 1
      else:
         time.sleep(1)
         current += 2

   #
   #   If the status fails by timeout, the test fails.
   #
   if ( mine is None or crlstat is None or idxstat is None ):
      print tname, ":  Collection status get failed"
      print tname, ":  Test Failed"
      sys.exit(1)

   return crlstat, idxstat

def start_or_restart_crawl(tname=None, xx=None, yy=None, collection=None):

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      sys.exit(1)

   colfile = ''.join([collection, '.xml'])

   cex = xx.collection_exists(collection=collection_name)
   if ( cex != 1 ):
      xx.create_collection(collection=collection_name, usedefcon=0)
      xx.start_crawl(collection=collection_name)
      xx.wait_for_idle(collection=collection_name)
      #print tname, ":  Initial crawl state, sleep for 180 seconds"
      time.sleep(3)
   else:
      xx.create_collection(collection=collection_name, usedefcon=0)
      xx.start_crawl(collection=collection_name)
      print tname, ":  Follow on crawl state, sleep for 5 seconds"
      time.sleep(5)

   return

if __name__ == "__main__":

   fail = 1

   collection_name = "files-2zz"
   tname = "files-2zz"
   colfile = collection_name + '.xml'
   cfgfile = collection_name + '.xml' + '.nix'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Source is Bug 25854"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   if ( xx.TENV.targetos == 'windows' ):
      cfgfile = collection_name + '.xml' + '.win'
   else:
      xx.is_testenv_mounted()

   shutil.copy(cfgfile, colfile)

   docount = 100
   current = 0

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection_api(collection=collection_name, force=1)

   start_or_restart_crawl(tname, xx, yy, collection_name)

   while ( current < docount ):  
      sleeptime = (current % 5) + 2
      #sleeptime = 300
      start_or_restart_crawl(tname, xx, yy, collection_name)
      crls, idxs = loop_on_status(yy=yy, collection=collection_name)
      print tname, ":  Services status, "

      if ( len(crls) >= 1 ):
         print tname, ":     Crawler status, ", crls[0]
      else:
         print tname, ":  No crawler status after 30 seconds"
         print tname, ":  Test Failed"
         sys.exit(1)

      if ( len(idxs) >= 1 ):
         print tname, ":     Indexer status, ", idxs[0]
      else:
         print tname, ":  No indexer status after 30 seconds"
         print tname, ":  Test Failed"
         sys.exit(1)

      if ( crls[0] == 'stopped' ):
         print tname, ":  Crawler status not running after 30 seconds"
         print tname, ":  Test Failed"
         sys.exit(1)

      if ( idxs[0] == 'stopped' ):
         print tname, ":  Indexer status not running after 30 seconds"
         print tname, ":  Test Failed"
         sys.exit(1)

      current += 1
      if ( current < docount ):
         print tname, ":  Sleep for", sleeptime, "seconds"
         time.sleep(sleeptime)

   ##############################################################

   xx.delete_collection_api(collection=collection_name, force=1)
   print tname, ":  Test Passed"
   sys.exit(0)

