#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This test is identical to files-2loop except it uses the old
#   way for creating and starting a collection and it runs in staging.
#
#   Test request from Stan in Bug 25854
#

import sys, time, cgi_interface, vapi_interface
import shutil, velocityAPI
from lxml import etree
import urllib2, getopt

def loop_on_crawler_status(yy=None, collection=None,
                           waitfor='stopped', subc='live'):

   if ( collection is None ):
      return "unknown"

   crlstat = None
   idxstat = None

   print tname, ":  Getting crawler status loop, max time is 120 seconds."
   max_loop = 120
   current = 0
   while ( current < max_loop ):

      print tname, ":  Getting crawler status only"
      #
      #   If the status fails, the test fails.
      #
      try:
         mine = yy.api_sc_status(collection=collection, subc=subc)
      except velocityAPI.VelocityAPIexception:
         print etree.tostring(mine)
         print tname, ":  Collection status get failed (loop_on_crawler_status)"
         print tname, ":  Test Failed"
         sys.exit(1)

      if ( mine is not None ):
         crlstat = mine.xpath('crawler-status/@service-status')
         print crlstat
         if ( len(crlstat) >= 1 ):
            if ( crlstat[0] != waitfor ):
               time.sleep(1)
               current += 1
            else:
               current = max_loop
         else:
            time.sleep(1)
            current += 1
      else:
         time.sleep(1)
         current += 1

   #
   #   If the status fails by timeout, the test fails.
   #
   if ( mine is None or crlstat is None ):
      print tname, ":  Collection status get failed(loop_on_crawler_status, end)"
      print tname, ":  Test Failed"
      sys.exit(1)

   return crlstat

def loop_on_status(yy=None, collection=None, subc='live'):

   if ( collection is None ):
      return "unknown"

   crlstat = None
   idxstat = None

   print tname, ":  Getting crawler/indexer status loop, max time is 120 seconds."
   max_loop = 120
   current = 0
   while ( current < max_loop ):

      print tname, ":  Getting crawler and indexer status"
      #
      #   If the status fails, the test fails.
      #
      try:
         mine = yy.api_sc_status(collection=collection, subc=subc)
      except:
         print tname, ":  Collection status get failed (loop_on_status)"
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
               current = max_loop
         else:
            time.sleep(1)
            current += 1
      else:
         time.sleep(1)
         current += 1

   #
   #   If the status fails by timeout, the test fails.
   #
   if ( mine is None or crlstat is None or idxstat is None ):
      print tname, ":  Collection status get failed (loop_on_status, final)"
      print tname, ":  Test Failed"
      sys.exit(1)

   return crlstat, idxstat

def start_or_restart_crawl(tname=None, xx=None, yy=None,
                           collection=None, stype='new', subc='live'):

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      sys.exit(1)

   colfile = ''.join([collection, '.xml'])

   cex = xx.collection_exists(collection=collection)
   if ( cex != 1 ):
      yy.api_sc_create(collection=collection, based_on='default-push')
      yy.api_repository_update(xmlfile=colfile)
      print tname, ":  Starting the crawl in", subc
      yy.api_sc_crawler_start(collection=collection,
                              stype='new', subc=subc)
      print tname, ":  Initial crawl state, sleep for 30 seconds"
      time.sleep(30)
      #xx.wait_for_idle(collection=collection)
   else:
      print tname, ":  STOPPING the crawler"
      yy.api_sc_crawler_stop(collection=collection, killit='false',
                             subc=subc)
      if ( stype == 'refresh-new' or stype == 'new' ):
         yy.api_sc_indexer_stop(collection=collection, killit='true',
                                subc=subc)
      loop_on_crawler_status(yy=yy, collection=collection, subc=subc)
      print tname, ":  Sleep 3 seconds before restart"
      time.sleep(3)
      print tname, ":  STARTING the crawler (", stype, ")"
      yy.api_sc_crawler_start(collection=collection, stype=stype,
                              subc=subc)
      loop_on_crawler_status(yy=yy, collection=collection, subc=subc,
                             waitfor='running')
      print tname, ":  Follow on crawl state, sleep for 5 seconds"
      time.sleep(5)

   return

def valid_restart(tname=None, stype=None):

   valid_list = ["new", "resume", "resume-and-idle",
                 "refresh-inplace", "refresh-new",
                 "apply-changes"]

   if ( stype is not None ):
      for item in valid_list:
         if ( item == stype ):
            return 1

   print tname, ":  Invalid start type.  Must be one of:"
   print tname, ": ", valid_list
   sys.exit(1)

   return 0

def failed_bailout(tname=None, xx=None, collection=None):

   xx.delete_collection(collection=collection)
   print tname, ":  Test Failed"
   sys.exit(1)

def valid_subcollection(tname=None, subc=None):

   valid_list = ["live", "staging"]

   if ( subc is not None ):
      for item in valid_list:
         if ( item == subc ):
            return 1

   print tname, ":  Invalid sub-collection type.  Must be one of:"
   print tname, ": ", valid_list
   sys.exit(1)

   return 0


if __name__ == "__main__":

   fail = 1

   subc = 'live'
   stype = 'refresh-inplace'

   collection_name = "crawl-stop-start"
   tname = "crawler-stop-start"
   colfile = collection_name + '.xml'

   opts, args = getopt.getopt(sys.argv[1:], "C:S:T:", ["subcollection=", "starttype=", "testname="])

   for o, a in opts:
      if o in ("-C", "--subcollection"):
         subc = a
      if o in ("-S", "--starttype"):
         stype = a
      if o in ("-T", "--testname"):
         tname = a

   valid_restart(tname, stype)
   valid_subcollection(tname, subc)

   print tname, ":  Restart mode  =", stype
   print tname, ":  Subcollection =", subc

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Source is Bug 25854"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   docount = 5
   current = 0
   MaskKill = True

   if ( xx.TENV.vivfloatversion < 7.5 ):
      MaskKill = False

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      print tname, ":  This collection should probably have been gone before now."
      print tname, ":  Attempting to delete it ..."
      if ( not MaskKill ):
         xx.delete_collection_api(collection=collection_name, force=1)

   if ( MaskKill ):
      print tname, ":  Forced delete of collection, whether it exists or not."
      #
      #   Using this method invalidates the test before 7.5-5 since that is
      #   when the option was added to the search-collection-delete api call.
      #   If this needs to be run in earlier versions, set the MaskKill value
      #   above to False.
      #
      yy.vapi.search_collection_delete(collection=collection_name,
                                       force='true',
                                       kill_services='true')
   else:
      cex = xx.collection_exists(collection=collection_name)
      if ( cex == 1 ):
         print tname, ":  Collection still exists and it should not."
         print tname, ":     1) There is probably a process related to the collection"
         print tname, ":        which did not die when the crawler was killed."
         print tname, ":     2) There is a partial collection (just files?) laying"
         print tname, ":        about which a normal delete can not get rid of."

   start_or_restart_crawl(tname=tname, xx=xx, yy=yy,
                          collection=collection_name,
                          stype=stype, subc=subc)

   while ( current < docount ):
      sleeptime = (current % 5) + 2
      print tname, ":  Iteration", current + 1, "of", docount
      #sleeptime = 300
      start_or_restart_crawl(tname=tname, xx=xx, yy=yy,
                             collection=collection_name,
                             stype=stype, subc=subc)
      crls, idxs = loop_on_status(yy=yy, collection=collection_name,
                                  subc=subc)
      print tname, ":  Services status, "

      if ( len(crls) >= 1 ):
         print tname, ":     Crawler status, ", crls[0]
      else:
         print tname, ":  No crawler status after 30 seconds"
         failed_bailout(tname=tname, xx=xx, collection=collection_name)

      if ( len(idxs) >= 1 ):
         print tname, ":     Indexer status, ", idxs[0]
      else:
         print tname, ":  No indexer status after 30 seconds"
         failed_bailout(tname=tname, xx=xx, collection=collection_name)

      if ( crls[0] == 'stopped' ):
         print tname, ":  Crawler status not running after 30 seconds"
         failed_bailout(tname=tname, xx=xx, collection=collection_name)

      if ( idxs[0] == 'stopped' ):
         print tname, ":  Indexer status not running after 30 seconds"
         failed_bailout(tname=tname, xx=xx, collection=collection_name)

      current += 1
      if ( current < docount ):
         print tname, ":  Sleep for", sleeptime, "seconds"
         time.sleep(sleeptime)

   ##############################################################

   xx.delete_collection_api(collection=collection_name, force=1)
   print tname, ":  Test Passed"
   sys.exit(0)

