#!/usr/bin/python

#
#   Test of the api
#   This test is for scheduler-service-start and
#   scheduler-service-stop.  It starts and stops
#   the scheduler service in a loop.  It is very
#   basic in that it starts the scheduler with no
#   scheduled tasks.
#

import sys, time, cgi_interface

def get_job_id_status(xx=None, vfunc=None, jobid=None):

   cmd = "xsltproc"

   if ( jid == None ):
      return

   if ( vfunc == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode jid-status --stringparam mytrib ', jobid])
   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y

def get_job_id_list(xx=None, vfunc=None):

   cmd = "xsltproc"

   if ( vfunc == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode job-id-list'])
   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y.split('\n')

def test_function2(xx=None, vfunc=None):

   if ( vfunc == None ):
      return

   if ( xx.TENV.targetos == "windows" ):
      httpcmd = "/vivisimo/cgi-bin/velocity.exe"
   else:
      httpcmd = "/vivisimo/cgi-bin/velocity"

   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

   appname = 'api-rest'

   httpstring = ''.join(['v.app=', appname,
                         '&v.function=', vfunc])

   err = xx.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=dumpit)

   return

def test_function(xx=None, vfunc=None, source=None, jobid=None):

   if ( source == None ):
      return

   if ( vfunc == None ):
      return

   if ( xx.TENV.targetos == "windows" ):
      httpcmd = "/vivisimo/cgi-bin/velocity.exe"
   else:
      httpcmd = "/vivisimo/cgi-bin/velocity"

   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

   appname = 'api-rest'
   emull = 'false'
   degub = 'false'

   if ( jobid == None ):
      httpstring = ''.join(['v.app=', appname,
                            '&source=', source,
                            '&email=', emull,
                            '&debug=', degub,
                            '&v.function=', vfunc])
   else:
      httpstring = ''.join(['v.app=', appname,
                            '&source=', source,
                            '&job-id=', jobid,
                            '&v.function=', vfunc])

   err = xx.HTTP.doget(tocmd=httpcmd, argstring=httpstring, dumpfile=dumpit)

   return

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_start = cs_stop = 0

   ##############################################################
   print "api-source-test-start-stop-1:  ##################"
   print "api-source-test-start-stop-1:  INITIALIZE"
   print "api-source-test-start-stop-1:  source-test-service-start/stop"
   xx = cgi_interface.CGIINTERFACE()

   thebeginning = time.time()

   ##############################################################
   print "api-source-test-start-stop-1:  ##################"
   print "api-source-test-start-stop-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "api-source-test-start-stop-1:", i, "of", maxcount

      ##############################################################
      print "api-source-test-start-stop-1:  ##################"
      print "api-source-test-start-stop-1:  START"

      test_function(xx=xx, vfunc='source-test-start', source='CNN')

      ##############################################################
   #
   #   Get the pid of the source test service to be sure one is running
   #
   sc_pid_current = xx.get_service_pid_list(service="source-test")
   if ( sc_pid_current == [] ):
      print "api-source-test-start-stop-1:  source testing did not start"
      print "api-source-test-start-stop-1:  Test Failed"
      sys.exit(1)

   #
   #   Get the job status
   #
   test_function2(xx=xx, vfunc='source-test-service-status-xml')

   #
   #   Get the job list
   #
   jlist = get_job_id_list(xx=xx, vfunc='source-test-service-status-xml')

   #
   #   Make sure we got at least "maxcount" entries
   #
   for jid in jlist:
      if ( jid != '' ):
         cs_start = cs_start + 1

   if ( cs_start != maxcount ):
      print "api-source-test-start-stop-1:  Jobs started or found,", cs_start
      print "api-source-test-start-stop-1:  Jobs expectd,         ", maxcount
   #
   #   Stop each source test job entry
   #
   for jid in jlist:
      if ( jid != '' ):
         print "api-source-test-start-stop-1:  STOP source test job:", jid
         test_function(xx=xx, vfunc='source-test-stop', source='CNN', jobid=jid)


   #
   #   Get the modified job status
   #
   test_function2(xx=xx, vfunc='source-test-service-status-xml')
   for jid in jlist:
      if ( jid != '' ):
         print "api-source-test-start-stop-1:  STATUS of source test job:", jid
         res = get_job_id_status(xx=xx, vfunc='source-test-service-status-xml', jobid=jid)
         print "api-source-test-start-stop-1:                            ", res
         if ( res == 'done' or res == 'aborted' or res == 'aborting' ):
            cs_stop = cs_stop + 1
         else:
            print "api-source-test-start-stop-1:  Jobs stop failed,", jid

   #
   #   Make sure the source test service quits; after all, we aborted
   #   everything
   #
   runcount = 0
   sc_pid_next = xx.get_service_pid_list(service="source-test")
   while ( sc_pid_next != [] ):
      time.sleep(1)
      runcount = runcount + 1
      if ( runcount > 20 ):
         print "api-source-test-start-stop-1:  source testing does not stop"
         print "api-source-test-start-stop-1:  Test Failed"
         sys.exit(1)
      else:
         print "api-source-test-start-stop-1:  source testing still running ..."
         sc_pid_next = xx.get_service_pid_list(service="source-test")

   if ( cs_start == 10 and cs_stop == 10 ):
      print "api-source-test-start-stop-1:  Test Passed"
      sys.exit(0)

   print "api-source-test-start-stop-1:  Test Failed"
   sys.exit(1)
