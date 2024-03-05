#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface

def get_current_pid_count(collection=None, last_count=0):

   iters = 0
   maxiter = 60
   pid_count = last_count

   while ( pid_count == last_count and iters < maxiter ):
      iters = iters + 1
      time.sleep(1)
      pid_count = int(xx.get_service_pid_count(service="crawler", collection=collection_name))

   return pid_count

if __name__ == "__main__":

   collection_name = "asccs-1"
   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_start = cs_stop = 0

   ##############################################################
   print "api-sc-crawler-start-stop-1:  ##################"
   print "api-sc-crawler-start-stop-1:  INITIALIZE"
   print "api-sc-crawler-start-stop-1:  search-collection-crawler-start/stop"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=1)
   xx.start_crawl(collection=collection_name, which='live')
   sc_pid_count = get_current_pid_count(collection=collection_name)
   sc_pid_current = sc_pid_count
   sc_pid_list = xx.get_service_pid_list(service="crawler",
                                         collection=collection_name)

   print "api-sc-crawler-start-stop-1:  initial crawler pid list,", sc_pid_list

   ##############################################################
   print "api-sc-crawler-start-stop-1:  ##################"
   print "api-sc-crawler-start-stop-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "api-sc-crawler-start-stop-1:", i, "of", maxcount

      ##############################################################
      print "api-sc-crawler-start-stop-1:  ##################"
      print "api-sc-crawler-start-stop-1:  STOP"

      yy.api_sc_crawler_stop(xx=xx, collection=collection_name, num=i)
      time.sleep(2)
      sc_pid_current = get_current_pid_count(collection=collection_name,
                                             last_count=sc_pid_current)
      if ( sc_pid_current != ( sc_pid_count - 1 ) ):
         sc_pid_list = xx.get_service_pid_list(service="crawler",
                                               collection=collection_name)
         print "api-sc-crawler-start-stop-1:  search-collection-crawler-stop failed,", sc_pid_list
         print "api-sc-crawler-start-stop-1:     alternate stop method"
         xx.stop_crawl(collection=collection_name, force=1)
         sc_pid_current = get_current_pid_count(collection=collection_name,
                                                last_count=sc_pid_current)
         if ( sc_pid_current != ( sc_pid_count - 1 ) ):
            print "api-sc-crawler-start-stop-1:  Could not stop crawler", sc_pid_current, sc_pid_count
            print "api-sc-crawler-start-stop-1:  Test Failed"
            sys.exit(99)
      else:
         cs_stop = cs_stop + 1

      ##############################################################
      print "api-sc-crawler-start-stop-1:  ##################"
      print "api-sc-crawler-start-stop-1:  START"
      yy.api_sc_crawler_start(xx=xx, collection=collection_name,
                              stype='resume')
      sc_pid_current = get_current_pid_count(collection=collection_name,
                                             last_count=sc_pid_current)
      if ( sc_pid_current != sc_pid_count ):
         sc_pid_list = xx.get_service_pid_list(service="crawler",
                                               collection=collection_name)
         print "api-sc-crawler-start-stop-1:  search-collection-crawler-start failed,", sc_pid_list
         print "api-sc-crawler-start-stop-1:     alternate start method"
         xx.start_crawl(collection=collection_name)
         sc_pid_current = get_current_pid_count(collection=collection_name,
                                                last_count=sc_pid_current)
         if ( sc_pid_current != sc_pid_count ):
            print "api-sc-crawler-start-stop-1:  Could not start crawler", sc_pid_current, sc_pid_count
            print "api-sc-crawler-start-stop-1:  Test Failed"
            sys.exit(99)
      else:
         cs_start = cs_start + 1

      ##############################################################

   xx.stop_crawl(collection=collection_name, force=1)
   xx.stop_indexing(collection=collection_name, force=1)

   if ( cs_start == 10 and cs_stop == 10 ):
      yy.cleanup_collection(collection_name, delete=True)
      print "api-sc-crawler-start-stop-1:  Test Passed"
      sys.exit(0)

   print "api-sc-crawler-start-stop-1:  Test Failed"
   sys.exit(1)
