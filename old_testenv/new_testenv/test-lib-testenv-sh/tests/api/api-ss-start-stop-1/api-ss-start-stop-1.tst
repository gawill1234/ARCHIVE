#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface

if __name__ == "__main__":

   ss_start = ss_stop = 0
   maxcount = 10

   print "api-ss-start-stop-1:  search-collection-create/search-collection-delete"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   qscount_start = int(xx.get_service_pid_count(service="query-all"))
   #
   #   There should be at least 2 query-service processes running
   #   Make sure the start value is at least 2.
   #
   if ( qscount_start < 2 ):
      print "api-ss-start-stop-1:  WARNING, incorrect number of query-services running,", qscount_start
      qscount_start = 2

   #
   #   Stop any currently runnint query services
   #
   if ( xx.query_service_status() == 1 ):
      print "api-ss-start-stop-1:  search service running, stopping" 
      xx.stop_query_service()

   #
   #   Make sure search services quit.  If not, exit.
   #
   if ( xx.query_service_status() == 1 ):
      print "api-ss-start-stop-1:  search service still running, exiting" 
      sys.exit(99)
   else:
      print "api-ss-start-stop-1:  search service stopped, continuing" 

   #
   #   Start and stop the search service 10 times.  Check to make
   #   sure each operation succeeded.
   #
   z = 0
   while ( z < maxcount ):
      z = z + 1

      print ""
      print "api-ss-start-stop-1:  Iteration", z, "of", maxcount

      print "api-ss-start-stop-1:  Starting search service"
      yy.api_ss_start(xx=xx)
      if ( xx.query_service_status() == 1 ):
         ss_start = ss_start + 1
         print "api-ss-start-stop-1:  Stopping search service"
         yy.api_ss_stop(xx=xx)
         if ( xx.query_service_status() != 1 ):
            ss_stop = ss_stop + 1
         else:
            print "api-ss-start-stop-1:  search service stop failed"
      else:
         print "api-ss-start-stop-1:  search service start failed"

   #
   #   Attempt to restore the search service to the pre-test state
   #
   print "api-ss-start-stop-1:  Restarting search service"
   xx.start_query_service()

   #
   #   Find out how many search services we ended up with.
   #
   qscount_end = int(xx.get_service_pid_count(service="query-all"))

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( ss_start == maxcount and ss_stop == maxcount ):
      if ( qscount_start == qscount_end ):
         print "api-ss-start-stop-1:  Test Passed"
         sys.exit(0)
      else:
         print "api-ss-start-stop-1:  Number of running query services is not correct"
         print "api-ss-start-stop-1:     expected:", qscount_start, " actual:", qscount_end
         

   print "api-ss-start-stop-1:  Test Failed"
   sys.exit(1)
