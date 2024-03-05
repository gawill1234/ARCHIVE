#!/usr/bin/python

#
#   Test of the api
#   This test is for scheduler-service-start and
#   scheduler-service-stop.  It starts and stops
#   the scheduler service in a loop.  It is very
#   basic in that it starts the scheduler with no
#   scheduled tasks.
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
      print "api-sched-start-stop-1:  start/stop happened correctly"
      print "api-sched-start-stop-1:    start pid list =  ", l1
      print "api-sched-start-stop-1:    restart pid list =", l2
   else:
      print "api-sched-start-stop-1:  No start happened"
      print "api-sched-start-stop-1:    start pid list =  ", l1
      print "api-sched-start-stop-1:    restart pid list =", l2

   return retval

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_start = cs_stop = 0
   sc_pid_start = ['0']

   ##############################################################
   print "api-sched-start-stop-1:  ##################"
   print "api-sched-start-stop-1:  INITIALIZE"
   print "api-sched-start-stop-1:  scheduler-service-start/stop"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   thebeginning = time.time()

   ##############################################################
   print "api-sched-start-stop-1:  ##################"
   print "api-sched-start-stop-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "api-sched-start-stop-1:", i, "of", maxcount

      ##############################################################
      print "api-sched-start-stop-1:  ##################"
      print "api-sched-start-stop-1:  START"

      yy.api_sched_srv_start(xx=xx)
      time.sleep(4)
      sc_pid_current = xx.get_service_pid_list(service="scheduler")
      cs_start = cs_start + list_compare(l1=sc_pid_start,
                                         l2=sc_pid_current)
      sc_pid_start = sc_pid_current

      ##############################################################
      print "api-sched-start-stop-1:  ##################"
      print "api-sched-start-stop-1:  STOP"
      try:
         yy.api_sched_srv_stop(xx=xx)
         time.sleep(20)
         sc_pid_current = xx.get_service_pid_list(service="scheduler")
      except:
         try:
            yy.api_sched_srv_stop(xx=xx)
            time.sleep(20)
            sc_pid_current = xx.get_service_pid_list(service="scheduler")
         except:
            print "api-sched-start-stop-1:  Stop failed after 40 seconds"
            cs_stop = cs_stop + 1


      if ( sc_pid_current != [] ):
         print "api-sched-start-stop-1:  scheduler-service-stop failed,", sc_pid_current
      else:
         cs_stop = cs_stop + 1

      ##############################################################

   if ( cs_start == 10 and cs_stop == 10 ):
      print "api-sched-start-stop-1:  Test Passed"
      sys.exit(0)

   print "api-sched-start-stop-1:  Test Failed"
   sys.exit(1)
