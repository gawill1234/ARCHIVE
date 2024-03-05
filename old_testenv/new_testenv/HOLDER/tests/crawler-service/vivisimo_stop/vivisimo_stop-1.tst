#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface 

query = 0
crawler = 1
indexer = 2
scheduler = 3
report = 4
source = 5
alert = 6
admin = 7
collectionservice = 8
executeworker = 9

service_list = ['query-all', 'crawler', 'indexer', 'scheduler',
                'report', 'source-test', 'alert', 'admin',
                'collection-service-all', 'execute-worker']

def get_current_pid_count(xx, pid_list=None):

   iters = 0
   maxiter = 60
   pid_count = 0
   print "vivisimo_stop-1:  Getting PID count for all services"

   for item in service_list:
      sserv = 0
      time.sleep(1)
      sserv = xx.get_service_pid_count(service=item)
      print "vivisimo_stop-1:     PID count for", item, ":", sserv
      pid_count = pid_count + int(sserv)
      pid_list[iters] = int(sserv)
      iters = iters + 1

   return pid_count

if __name__ == "__main__":

   collection_name = "vivstp-1"
   pid_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
   old_list = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
   exp_list = [2, 0, 0, 1, 0, 0, 0, 0, 0, 1]
   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_start = cs_stop = 0

   ##############################################################
   print "vivisimo_stop-1:  ##################"
   print "vivisimo_stop-1:  INITIALIZE"
   print "vivisimo_stop-1:  search-collection-crawler-start/stop"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.1)

   bindir = xx.vivisimo_dir(which="bin")
   if ( xx.TENV.targetos == "windows" ):
      sep = '\\'
      stopcmd = 'velocity-shutdown.exe'
      strtcmd = 'velocity-startup.exe'
   else:
      sep = '/'
      stopcmd = 'velocity-shutdown'
      strtcmd = 'velocity-startup'

   vstop = ''.join([bindir, sep, stopcmd, ' -y'])
   vstart = ''.join([bindir, sep, strtcmd, ' -y'])

   #xx.create_collection(collection=collection_name, usedefcon=1)
   #xx.start_crawl(collection=collection_name)

   sc_pid_count = get_current_pid_count(xx=xx, pid_list=pid_list)
   if ( sc_pid_count <= 0 ):
      print "vivisimo_stop-1:  Processes should be running"
      print "vivisimo_stop-1:  There are none"
      print "vivisimo_stop-1:  Test Failed"
      sys.exit(1)


   print "vivisimo_stop-1:  initial pid count,", sc_pid_count

   ##############################################################
   print "vivisimo_stop-1:  ##################"
   print "vivisimo_stop-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):

      i = i + 1
      print "vivisimo_stop-1:", i, "of", maxcount
      print "vivisimo_stop-1:   Stopping all vivisimo processes"
      print "vivisimo_stop-1:      ", vstop
      xx.execute_command(cmd=vstop)
      time.sleep(120)
      sc_pid_count = get_current_pid_count(xx=xx, pid_list=old_list)

      print "vivisimo_stop-1:      process count should be 0"
      print "vivisimo_stop-1:      it is:", sc_pid_count
      if ( sc_pid_count != 0 ):
         print "vivisimo_stop-1:   Test Failed"
         sys.exit(1)
      else:
         cs_stop = cs_stop + 1

      iters = 0
      for item in service_list:
         old_list[iters] = pid_list[iters]
         iters = iters + 1

      print "vivisimo_stop-1:   Restarting all vivisimo processes"
      print "vivisimo_stop-1:      ", vstart
      xx.execute_command(cmd=vstart)
      time.sleep(120)
      sc_pid_count = get_current_pid_count(xx=xx, pid_list=pid_list)

      print "vivisimo_stop-1:      process count should be greater than 0"
      print "vivisimo_stop-1:      it is:", sc_pid_count
      if ( sc_pid_count <= 0 ):
         print "vivisimo_stop-1:   Test Failed"
         sys.exit(1)
      else:
         iters = 0
         for item in service_list:
            print "vivisimo_stop-1:      Processes for", item
            print "vivisimo_stop-1:         Expected:", exp_list[iters]
            print "vivisimo_stop-1:         Actual  :", pid_list[iters]
            if ( exp_list[iters] != pid_list[iters] ):
               print "vivisimo_stop-1:         Wrong number of processes"
               print "vivisimo_stop-1:   Test Failed"
               xx.start_query_service()
               sys.exit(1)
            iters = iters + 1
         cs_start = cs_start + 1

      ##############################################################

   xx.stop_crawl(collection=collection_name, force=1)
   yy.api_sc_delete(xx=xx, collection=collection_name)

   if ( cs_start == 10 and cs_stop == 10 ):
      print "vivisimo_stop-1:  Test Passed"
      sys.exit(0)

   print "vivisimo_stop-1:  Test Failed"
   sys.exit(1)
