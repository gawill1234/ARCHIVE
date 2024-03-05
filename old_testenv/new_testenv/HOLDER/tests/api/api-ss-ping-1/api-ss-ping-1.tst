#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import os, sys, time, cgi_interface 

def get_ping_value(xx=None, vfunc=None):

   cmd = "xsltproc"

   if ( vfunc == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = "--stringparam mynode search-service-ping"
   dumpit = ''.join(['querywork/', vfunc, '.wazzat'])

   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   #
   #   Remove the result file so previous results are not
   #   mistaken for current results
   #
   os.remove(dumpit)

   return y

def test_function(xx=None, vfunc=None):

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



if __name__ == "__main__":

   ss_ping = 0
   maxcount = 10

   print "api-ss-ping-1:  search-service-ping api"
   xx = cgi_interface.CGIINTERFACE()

   #
   #   Get the vivisimo install directory.  This is the
   #   expected result from a search service ping
   #
   dir = xx.vivisimo_dir()

   #
   #   Start the query service if it is stopped.
   #
   if ( xx.query_service_status() != 1 ):
      print "api-ss-ping-1:  search service stopped, starting" 
      xx.start_query_service()

   #
   #   Make sure search services are running.  If not, exit.
   #
   if ( xx.query_service_status() != 1 ):
      print "api-ss-ping-1:  search service did not start, exiting" 
      sys.exit(99)
   else:
      print "api-ss-ping-1:  search service running, continuing" 

   #
   #   Ping the search service 10 times.  Check to make
   #   sure each operation succeeded.
   #
   z = 0
   while ( z < maxcount ):

      z = z + 1

      print ""
      print "api-ss-ping-1:  Iteration", z, "of", maxcount

      print "api-ss-ping-1:  Ping search service"
      test_function(xx=xx, vfunc='search-service-ping')
      pingdir = get_ping_value(xx=xx, vfunc='search-service-ping')
      if ( dir == pingdir ):
         print "api-ss-ping-1:  ping result, success"
         ss_ping = ss_ping + 1
      else:
         print "api-ss-ping-1:  ping result, failure"

      print "api-ss-ping-1:     Actual  ,", pingdir
      print "api-ss-ping-1:     Expected,", dir


   #
   #   If any of the starts or stops failed, or if the wrong number
   #   of search services are running, skip to the end and fail
   #   Otherwise, test passed
   #
   if ( ss_ping == maxcount ):
      print "api-ss-ping-1:  Test Passed"
      sys.exit(0)
         
   print "api-ss-ping-1:  Test Failed"
   sys.exit(1)
