#!/usr/bin/python

#
#   CNN CNN CNN CNN CNN CNN ... Hi Bruce ;b
#
#   This tests that <crawl-state> node can be enqueued and that the
#   state is subsequently sent to the connector.
#
#   Parts:
#      rubicon.rb:  A fake connector.  It goes into vivsimo/bin.
#      scrubby_rat: A file created by rubicon.rb.  Should contain
#                   the crawl-state that was enqueued.
#      log.sqlt:    Created by the crawler.  The token-state table
#                   should contain the crawl-state that was enqueued.
#
#   This test:
#      Puts rubicon.rb into <velocity>/bin
#      Makes rubicon.rb executable
#      starts the crawler which runs rubicon.rb
#      enqueues the crawl-state values
#      gets the log.sqlt
#      check token-state table for crawl-state value
#      restart the crawler which runs rubicon.rb
#      rubicon.rb then dumps its data from the crawler into
#         scrubby_rat file
#      get scrubby_rat
#      checks scrubby_rat for the crawl-state value
#      if all of that stuff checks out, the test passes.
#

#
#
import os, sys, cgi_interface, vapi_interface
import host_environ, build_schema_node
import velocityAPI
from lxml import etree

def collection_reset(srvr, collection_name):

   collection_xml = collection_name + '.xml'

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = srvr.cgi.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      srvr.cgi.delete_collection(collection=collection_name)

   srvr.vapi.api_sc_create(collection=collection_name, based_on='default-push')
   #srvr.vapi.api_repository_update(xmlfile=collection_xml)

   srvr.vapi.api_sc_crawler_start(collection=collection_name)

   return

def pusher(srvr, collection_name):

   pushsuccess = False

   bark = build_schema_node.create_crawl_url(url='http://myjunk.xxx/whoa',
               status='complete', enqueuetype='reenqueued',
               synchronization='indexed-no-sync')
   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='text/html', addnodeto=bark,
                text="You are busted.")

   print etree.tostring(bark)

   try:
      resp = srvr.vapi.api_sc_enqueue_xml(collection=collection_name, 
                                          crawl_nodes=etree.tostring(bark))
      pushsuccess = True
   except:
      print tname, ":  The enqueue failed horribly!!"

   if ( resp is not None ):
      print tname, ":", etree.tostring(resp)
   else:
      print tname, ":  No response from the <crawl-state> enqueue"

   return pushsuccess

#
#   End of identical routines, sort of.
#
#####################################################################

if __name__ == "__main__":

   fail = 0
   foundcrap = False

   tname = 'quick-stop'
   collection_name = tname

   hostname = os.getenv('VIVHOST', None)
   srvr = host_environ.HOSTENVIRON(hostname=hostname)

   srvr.cgi.version_check(minversion=8.0)

   sep = '/'
   if ( srvr.cgi.TENV.targetos == 'windows' ):
      sep = '\\'

   ###############################################################

  
   print "#######################################################"

   collection_reset(srvr, collection_name)
   try:
      srvr.vapi.api_sc_crawler_restart(collection=collection_name)
      srvr.cgi.delete_collection(collection=collection_name)
      sc_pid_count = int(srvr.cgi.get_service_pid_count(service='indexer'))
      if (sc_pid_count != 0 ):
         fail += 1
         print tname, ":  UP, An indexer is still running and it should not be"
         srvr.vapi.api_sc_crawler_stop(collection=collection_name,
                                       killit='true')
         srvr.vapi.api_sc_indexer_stop(collection=collection_name,
                                       killit='true')
   except:
      print tname, ":  Oh, you have got to be kidding!!"
      print tname, ":  A basic quick delete failed!"
      fail += 1

   collection_reset(srvr, collection_name)

   if ( pusher(srvr, collection_name) ):

      try:
         srvr.vapi.api_sc_crawler_restart(collection=collection_name)
         srvr.cgi.delete_collection(collection=collection_name)
         sc_pid_count = int(srvr.cgi.get_service_pid_count(service='indexer'))
         if (sc_pid_count != 0 ):
            fail += 1
            print tname, ":  DOWN, An indexer is still running and it should not be"
            srvr.vapi.api_sc_crawler_stop(collection=collection_name,
                                          killit='true')
            srvr.vapi.api_sc_indexer_stop(collection=collection_name,
                                          killit='true')
      except:
         print tname, ":  AWWW, nuts!!"
         print tname, ":  A quick delete after a crawl-state enqueue failed!"
         fail += 1

   else:
      print tname, ":  push failed for <crawl-state>?"
      fail += 1

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
