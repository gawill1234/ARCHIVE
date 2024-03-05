#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface

def list_compare(l1=[], l2=[]):

   yago = "barf"
   retval = 0

   for item in l1:
      if ( item != '' ):
         for item2 in l2:
            if ( item2 != '' ):
              if ( item != item2 ):
                 yago = "settled"

   if ( yago == "settled" ):
      retval = 1
      print "api-sc-indexer-restart-2:  Restart happened correctly"
      print "api-sc-indexer-restart-2:    start pid list =  ", l1
      print "api-sc-indexer-restart-2:    restart pid list =", l2
   else:
      print "api-sc-indexer-restart-2:  No restart happened"
      print "api-sc-indexer-restart-2:    start pid list =  ", l1
      print "api-sc-indexer-restart-2:    restart pid list =", l2

   return retval

if __name__ == "__main__":

   collection_name = "ascir-2"
   colfile = ''.join([collection_name, '.xml'])
   maxcount = 5
   i = 0
   cs_start = 0

   ##############################################################
   print "api-sc-indexer-restart-2:  ##################"
   print "api-sc-indexer-restart-2:  INITIALIZE"
   print "api-sc-indexer-restart-2:  search-collection-indexer-restart"
   print "api-sc-indexer-restart-2:     Initial work done with API"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   yy.api_sc_create(xx=xx, collection=collection_name)
   yy.api_repository_update(xx=xx, xmlfile=colfile)

   thebeginning = time.time()
   yy.api_sc_indexer_start(xx=xx, collection=collection_name)
   yy.api_sc_crawler_start(xx=xx, collection=collection_name)
   sc_pid_list_start = xx.get_service_pid_list(service="indexer",
                                               collection=collection_name)

   print "api-sc-indexer-restart-2:  initial crawler pid list,", sc_pid_list_start

   ##############################################################
   print "api-sc-indexer-restart-2:  ##################"
   print "api-sc-indexer-restart-2:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "api-sc-indexer-restart-2:", i, "of", maxcount

      ##############################################################
      print "api-sc-indexer-restart-2:  ##################"
      print "api-sc-indexer-restart-2:  RESTART"

      yy.api_sc_indexer_restart(xx=xx, collection=collection_name)
      time.sleep(180)
      sc_pid_list_current = xx.get_service_pid_list(service="indexer",
                                                    collection=collection_name)
      cs_start = cs_start + list_compare(l1=sc_pid_list_start,
                                         l2=sc_pid_list_current)

      sc_pid_list_start = sc_pid_list_current


   errcnt = xx.get_collection_system_errors(collection=collection_name,
                                            starttime=thebeginning)

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_start == maxcount ):
      yy.cleanup_collection(collection_name, delete=True)
      if ( errcnt != 0 ):
         print "api-sc-indexer-restart-2:  There were indexer errors, but ..."
      print "api-sc-indexer-restart-2:  Test Passed"
      sys.exit(0)

   print "api-sc-indexer-restart-2:  Test Failed"
   sys.exit(1)
