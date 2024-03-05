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

   ss_status = ss_start = ss_stop = 0
   maxcount = 10

   print "api-ss-status-1:  search-collection-create/search-collection-delete"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   #
   #   Stop any currently runnint query services
   #
   if ( xx.query_service_status() == 1 ):
      print "api-ss-status-1:  search service running, stopping" 
      xx.stop_query_service()

   #
   #   Make sure search services quit.  If not, exit.
   #
   if ( xx.query_service_status() == 1 ):
      print "api-ss-status-1:  search service still running, exiting" 
      sys.exit(1)
   else:
      print "api-ss-status-1:  search service stopped, continuing" 

   #
   #   Start and stop the search service 10 times.  Check to make
   #   sure each operation succeeded.
   #
   iter = 0
   while ( iter < maxcount ):
      iter = iter + 1

      print ""
      print "api-ss-status-1:  Iteration", iter, "of", maxcount

      #
      #
      print "api-ss-status-1:  Starting search service"
      yy.api_ss_start(xx=xx)

      #
      #   Get query service status with alternate status tool
      #
      z = xx.query_service_status()

      #
      #   Run search-service-status and get result
      #
      yy.api_ss_status(xx=xx)
      y = int(yy.get_status_value(xx=xx, vfunc='search-service-status'))

      #
      #   Make sure status results agree
      #
      if ( z == 1 and y > 0 ):
         ss_status = ss_status + 1
         print "api-ss-status-1:  Status says running"
      else:
         print "api-ss-status-1:  Status check disagreement"

      if ( z == 1 ):
         ss_start = ss_start + 1
         #
         #
         print "api-ss-status-1:  Stopping search service"
         yy.api_ss_stop(xx=xx)

         #
         #   Get query service status with alternate status tool
         #
         z = xx.query_service_status()

         #
         #   Run search-service-status and get result
         #
         yy.api_ss_status(xx=xx)
         y = int(yy.get_status_value(xx=xx, vfunc='search-service-status'))

         #
         #   Make sure status results agree
         #
         if ( z != 1 and y == 0 ):
            ss_status = ss_status + 1
            print "api-ss-status-1:  Status says stopped"
         else:
            print "api-ss-status-1:  Status check disagreement"

         if ( z != 1 ):
            ss_stop = ss_stop + 1
         else:
            print "api-ss-status-1:  search service stop failed"
      else:
         print "api-ss-status-1:  search service start failed"

   #
   #   Attempt to restore the search service to the pre-test state
   #
   print "api-ss-status-1:  Restarting search service"
   yy.api_ss_start(xx=xx)

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( ss_start == maxcount and ss_stop == maxcount and
        ss_status == ( maxcount * 2 ) ):
      print "api-ss-status-1:  Test Passed"
      sys.exit(0)
         

   print "api-ss-status-1:  Test Failed"
   sys.exit(1)
