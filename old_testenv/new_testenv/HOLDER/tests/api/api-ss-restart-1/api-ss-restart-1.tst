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

   yago = "settled"
   retval = 0

   for item in l1:
      if ( item != '' ):
         for item2 in l2:
            if ( item2 != '' ):
              if ( item == item2 ):
                 yago = "barf"

   if ( yago == "settled" ):
      retval = 1
      print "api-ss-restart-1:  Restart happened correctly"
      print "api-ss-restart-1:    start pid list =  ", l1
      print "api-ss-restart-1:    restart pid list =", l2
   else:
      print "api-ss-restart-1:  No restart happened"
      print "api-ss-restart-1:    start pid list =  ", l1
      print "api-ss-restart-1:    restart pid list =", l2

   return retval


if __name__ == "__main__":

   ss_start = 0
   maxcount = 10

   print "api-ss-restart-1:  search-service-restart api"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   qscount_start = int(xx.get_service_pid_count(service="query-all"))
   qslist_start = xx.get_service_pid_list(service="query-all")
   #
   #   There should be at least 2 query-service processes running
   #   Make sure the start value is at least 2.
   #
   if ( qscount_start < 2 ):
      print "api-ss-restart-1:  WARNING, incorrect number of query-services running,", qscount_start
      qscount_start = 2

   #
   #   Stop any currently runnint query services
   #
   if ( xx.query_service_status() == 1 ):
      print "api-ss-restart-1:  search service running, stopping"
      xx.stop_query_service()

   #
   #   Make sure search services quit.  If not, exit.
   #
   if ( xx.query_service_status() == 1 ):
      print "api-ss-restart-1:  search service still running, exiting"
      sys.exit(99)
   else:
      print "api-ss-restart-1:  search service stopped, continuing"

   print "api-ss-restart-1:  Starting (from dead) search service with restart"
   yy.api_ss_restart(xx=xx)
   qslist_current = xx.get_service_pid_list(service="query-all")
   ss_start = ss_start + list_compare(l1=qslist_start, l2=qslist_current)

   #
   #   Restart the search service 10 times.  Check to make
   #   sure each operation succeeded.
   #
   z = 0
   while ( z < maxcount ):

      qslist_start = qslist_current
      z = z + 1

      print ""
      print "api-ss-restart-1:  Iteration", z, "of", maxcount

      print "api-ss-restart-1:  Restarting (from running) search service with restart"
      yy.api_ss_restart(xx=xx)
      if ( xx.query_service_status() == 1 ):
         qslist_current = xx.get_service_pid_list(service="query-all")
         ss_start = ss_start + list_compare(l1=qslist_start, l2=qslist_current)


   #
   #   Find out how many search services we ended up with.
   #
   qscount_end = int(xx.get_service_pid_count(service="query-all"))
   if ( qscount_end != qscount_start ):
      qslist_end = xx.get_service_pid_list(service="query-all")
      qscount_end = int(xx.get_service_pid_count(service="query-all"))

   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( ss_start == ( maxcount + 1 ) ):
      if ( qscount_start == qscount_end ):
         print "api-ss-restart-1:  Test Passed"
         sys.exit(0)
      else:
         print "api-ss-restart-1:  Number of running query services is not correct"
         print "api-ss-restart-1:     expected:", qscount_start, " actual:", qscount_end
         print "api-ss-restart-1:     ", qslist_end


   print "api-ss-restart-1:  Successful restarts,", ss_start, "of", (maxcount + 1)
   print "api-ss-restart-1:  Test Failed"
   sys.exit(1)
