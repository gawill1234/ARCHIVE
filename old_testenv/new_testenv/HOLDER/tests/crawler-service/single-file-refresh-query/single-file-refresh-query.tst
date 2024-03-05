#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, os, cgi_interface 

def check_url_count(collection=None):

   queryfile = "querywork/myquery"
   xx.run_query(collection=collection, defoutput=queryfile)
   qcnt = int(xx.count_query_urls(filenm=queryfile))

   if ( qcnt != 1 ):
      print "single-file-refresh-1:  Query url count wrong"
      print "single-file-refresh-1:     Expected, 1"
      print "single-file-refresh-1:     Actual,", qcnt
      print "single-file-refresh-1:  exiting"
      print "single-file-refresh-1:  Test Failed"
      sys.exit(1)

   return qcnt

def check_pend(collection=None, mynum=0):

   interim = ''.join(['querywork/', collection, '.admin.xml'])

   pend = int(xx.get_crawl_pending(collection=collection_name))
   if ( pend != 0 and pend != 1 ):
      print "single-file-refresh-1:  crawl pending wrong"
      print "single-file-refresh-1:     Expected, 0 or 1"
      print "single-file-refresh-1:     Actual,", pend
      print "single-file-refresh-1:  exiting"
      print "single-file-refresh-1:  Test Failed"
      sys.exit(1)
   else:
      os.remove(interim)

   return mynum

def start_fresh(collection_name=None):

   if ( xx.collection_exists(collection_name) == 1 ):
      xx.delete_collection(collection=collection_name, force=1)

      if ( xx.collection_exists(collection_name) == 1 ):
         print "single-file-refresh-1:  Could not delete old collection, exiting"
         print "single-file-refresh-1:  Test Failed"
         sys.exit(99)

   return

def dothisaschild(xx=None, collection=None):

   pid = os.getpid()
   print "Starting", pid
   #xx = cgi_interface.CGIINTERFACE()

   ofile = ''.join(['querywork/single-file-refresh-query.', '%s' % pid])

   xx.run_query(collection=collection, defoutput=ofile)

   print "Completing", pid

   return


if __name__ == "__main__":

   starttime = time.time()
   err = 0
   collection_name = "sfrq-nix"
   maxcount = 100
   i = 0
   spawncnt = 10

   mypid = os.getpid()

   ##############################################################
   print "single-file-refresh-1:  ##################"
   print "single-file-refresh-1:  INITIALIZE"
   print "single-file-refresh-1:  Refresh one document quickly, repeatedly"
   xx = cgi_interface.CGIINTERFACE()

   if ( xx.TENV.targetos == "windows" ):
      collection_name = "sfrq-win"

   start_fresh(collection_name=collection_name)

   xx.create_collection(collection=collection_name, usedefcon=1)
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print "single-file-refresh-1:  ##################"
   print "single-file-refresh-1:  TEST LOOP BEGINS"

   while ( i < maxcount ):
      i = i + 1
      print "single-file-refresh-1:", i, "of", maxcount

      ##############################################################
      print "single-file-refresh-1:  ##################"
      print "single-file-refresh-1:  REFRESH"

      #
      #   sleep will be 0 or 1 second
      #
      time.sleep( ( i % 2 ) )

      i = check_pend(collection=collection_name, mynum=i)
      err = xx.refresh_crawl(collection=collection_name)
      j = 0
      while ( j < spawncnt ):
         try:
            pid = os.fork()
            if ( pid == 0 ):
               dothisaschild(xx=xx, collection=collection_name)
               sys.exit(0)
         except OSError, e:
            print "Fork failed"

         j = j + 1

      try:
         print "Waiting for kids ... "
         os.wait()
      except:
         print "Nothing to wait for"

      i = check_pend(collection=collection_name, mynum=i)


      ##############################################################

   xx.wait_for_idle(collection=collection_name)
   xx.stop_crawl(collection=collection_name, force=1)

   i = check_pend(collection=collection_name)
   qcnt = check_url_count(collection=collection_name)
   errcnt = xx.get_collection_system_errors(collection=collection_name, starttime=starttime)


   if ( i <= maxcount ):
      if ( qcnt == 1 ):
         if ( errcnt == 0 ):
            xx.delete_collection(collection=collection_name, force=1)
            print "single-file-refresh-1:  Test Passed"
            sys.exit(0)

   print "single-file-refresh-1:  Test Failed"
   sys.exit(1)
