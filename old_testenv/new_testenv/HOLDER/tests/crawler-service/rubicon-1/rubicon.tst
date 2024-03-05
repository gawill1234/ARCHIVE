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
import host_environ
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
   srvr.vapi.api_repository_update(xmlfile=collection_xml)

   srvr.vapi.api_sc_crawler_start(collection=collection_name)

   return

def pusher(srvr, collection_name):

   pushsuccess = False

   #
   #   Don't want to be having cuss words in these here strings ...
   #
   bark = "<crawl-state name=\"crapslang\">this is my value, girldog.</crawl-state>"

   try:
      resp = srvr.vapi.api_sc_enqueue_xml(collection=collection_name, 
                                          crawl_nodes=bark)
      srvr.cgi.get_remote_database(db="log", collection=collection_name)
      qres = srvr.cgi.run_db_query(dbfile='querywork/log.sqlt', 
                                   query='select * from token_state')
      print qres

      expqres = '0|crapslang|this is my value, girldog.'

      if ( expqres == qres.split('\n')[0] ):
         pushsuccess = True
   except:
      print tname, ":  The <crawl-state> enqueue failed horribly!!"

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

   tname = 'rubicon-1'
   collection_name = tname

   hostname = os.getenv('VIVHOST', None)
   srvr = host_environ.HOSTENVIRON(hostname=hostname)

   srvr.cgi.version_check(minversion=8.0)

   sep = '/'
   if ( srvr.cgi.TENV.targetos == 'windows' ):
      sep = '\\'

   instdir = srvr.cgi.vivisimo_dir() + sep + 'bin'
   fullname = instdir + sep + 'rubicon.rb'
   srvr.cgi.put_file(putfile='rubicon.rb', targetdir=instdir)
   srvr.cgi.make_remote_file_executable(filename=fullname)

   ###############################################################

  
   print "#######################################################"

   collection_reset(srvr, collection_name)

   if ( pusher(srvr, collection_name) ):

      try:
         srvr.vapi.api_sc_crawler_restart(collection=collection_name)
         srvr.cgi.wait_for_idle(collection=collection_name)
         crdir = srvr.cgi.get_crawl_dir(collection=collection_name)
         filetoget = crdir + sep + 'scrubby_rat'
         srvr.cgi.get_file(getfile=filetoget, dumpdir='querywork')
      except:
         print tname, ":  AWWW, nuts!!"
         fail += 1

      for line in open("querywork/scrubby_rat"):
         if "crapslang" in line:
            foundcrap = True

      if ( not foundcrap ):
         print tname, ":  did not find <crawl-state> crapslang"
         fail += 1
      else:
         print tname, ":  found <crawl-state> crapslang"

   else:
      print tname, ":  push failed for <crawl-state>?"
      fail += 1

   if ( fail == 0 ):
      srvr.cgi.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
