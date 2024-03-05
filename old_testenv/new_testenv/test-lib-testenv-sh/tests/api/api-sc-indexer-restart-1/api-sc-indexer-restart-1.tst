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
      print "api-sc-indexer-restart-1:  Restart happened correctly"
      print "api-sc-indexer-restart-1:    start pid list =  ", l1
      print "api-sc-indexer-restart-1:    restart pid list =", l2
   else:
      print "api-sc-indexer-restart-1:  No restart happened"
      print "api-sc-indexer-restart-1:    start pid list =  ", l1
      print "api-sc-indexer-restart-1:    restart pid list =", l2

   return retval

if __name__ == "__main__":

   collection_name = "ascir-1"
   colfile = ''.join([collection_name, '.xml'])
   maxcount = 5
   i = 0
   cs_start = 0

   ##############################################################
   print "api-sc-indexer-restart-1:  ##################"
   print "api-sc-indexer-restart-1:  INITIALIZE"
   print "api-sc-indexer-restart-1:  search-collection-indexer-restart"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name, which="live")

   time.sleep(2)

   sc_pid_list_start = xx.get_service_pid_list(service="indexer",
                                               collection=collection_name)

   print "api-sc-indexer-restart-1:  initial crawler pid list,", sc_pid_list_start

   ##############################################################
   print "api-sc-indexer-restart-1:  ##################"
   print "api-sc-indexer-restart-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "api-sc-indexer-restart-1:", i, "of", maxcount

      ##############################################################
      print "api-sc-indexer-restart-1:  ##################"
      print "api-sc-indexer-restart-1:  RESTART"

      yy.api_sc_indexer_restart(xx=xx, collection=collection_name)
      time.sleep(180)
      sc_pid_list_current = xx.get_service_pid_list(service="indexer",
                                                    collection=collection_name)
      cs_start = cs_start + list_compare(l1=sc_pid_list_start,
                                         l2=sc_pid_list_current)

      sc_pid_list_start = sc_pid_list_current


   errcnt = xx.get_collection_system_errors(collection=collection_name,
                                            starttime=thebeginning)

   yy.cleanup_collection(collection_name, delete=True)

   if ( cs_start == maxcount ):
      if ( errcnt != 0 ):
         print "api-sc-indexer-restart-1:  There were indexer errors, but ..."
      print "api-sc-indexer-restart-1:  Test Passed"
      sys.exit(0)

   print "api-sc-indexer-restart-1:  Test Failed"
   sys.exit(1)
