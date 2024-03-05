#!/usr/bin/python

import sys, time, cgi_interface, vapi_interface
import test_helpers, os

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
      print "api-sc-crawler-restart-1:  Restart happened correctly"
      print "api-sc-crawler-restart-1:    start pid list =  ", l1
      print "api-sc-crawler-restart-1:    restart pid list =", l2
   else:
      print "api-sc-crawler-restart-1:  No restart happened"
      print "api-sc-crawler-restart-1:    start pid list =  ", l1
      print "api-sc-crawler-restart-1:    restart pid list =", l2

   return retval

if __name__ == "__main__":

   collection_name = "asccr-1"
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])

   maxcount = 5
   i = 0
   cs_start = 0

   ##############################################################
   print "api-sc-crawler-restart-1:  ##################"
   print "api-sc-crawler-restart-1:  INITIALIZE"
   print "api-sc-crawler-restart-1:  search-collection-crawler-restart"
   print "api-sc-crawler-restart-1:     Initial work done with admin"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, "api-sc-crawler-restart-1")
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name, which="live")
   sc_pid_list_start = xx.get_service_pid_list(service="crawler",
                                               collection=collection_name)

   print "api-sc-crawler-restart-1:  initial crawler pid list,", sc_pid_list_start

   ##############################################################
   print "api-sc-crawler-restart-1:  ##################"
   print "api-sc-crawler-restart-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "api-sc-crawler-restart-1:", i, "of", maxcount

      ##############################################################
      print "api-sc-crawler-restart-1:  ##################"
      print "api-sc-crawler-restart-1:  RESTART"

      yy.api_sc_crawler_restart(xx=xx, collection=collection_name)
      good_restart = 0
      for tries in xrange(30):
         time.sleep(10)
         sc_pid_list_current = xx.get_service_pid_list(service="crawler",
                                                       collection=collection_name)
         good_restart = list_compare(l1=sc_pid_list_start,
                                     l2=sc_pid_list_current)

         if good_restart:
            cs_start = cs_start + 1
            break

      sc_pid_list_start = sc_pid_list_current


   errcnt = xx.get_collection_system_errors(collection=collection_name,
                                            starttime=thebeginning)

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_start == maxcount ):
      yy.cleanup_collection(collection_name, delete=True)
      os.remove(colfile)
      if ( errcnt != 0 ):
         print "api-sc-crawler-restart-1:  Errors found, but ..."
      print "api-sc-crawler-restart-1:  Test Passed"
      sys.exit(0)

   print "api-sc-crawler-restart-1:  Test Failed"
   sys.exit(1)
