#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This is the basic crawl test created to test SPOC
#   (the new sharepooint connector).  This test does
#   A)  A basic crawl
#   B)  A data update and refresh
#   C)  A large data update and refresh while the data is updating
#       followed by a terminating update to get final data.
#
#   This test is used for both sharepoint 2007 and 2010.  There is a
#   site for each with identical data.
#
#   If the data indicates that the queried/returned data is different
#   than expected, check that near duplicate mathing is not eliminating
#   some results of the queries.  The shingles word count has been set
#   to 20 with the default check count of 14 still in place to shrink the
#   possibility of a duplcation to near 0, however the possibility does
#   exist for an unexpected flagging of two files being duplicates.
#
#

import sys, time, cgi_interface, vapi_interface 
import velocityAPI, simpleLock
import os, getopt
import doc_updater
from lxml import etree

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

#
#   Start the initial crawl.
#
def Start_The_Crawl_No_Wait(tname=None, xx=None, yy=None, collection=None):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
      sys.exit(1)

   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection, force=1)

   colfile = ''.join([collection, '.xml'])

   yy.api_sc_create(collection=collection, based_on='default')
   yy.api_repository_update(xmlfile=colfile)
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')
   #stime = time.time()
   #xx.wait_for_idle(collection=collection)
   #etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return
#
#   Start the initial crawl.
#
def Start_The_Crawl(tname=None, xx=None, yy=None, collection=None):

   stime = etime = 0

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      raise Exception("Collection Error")
      sys.exit(1)

   cex = xx.collection_exists(collection=collection)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection, force=1)

   colfile = ''.join([collection, '.xml'])

   yy.api_sc_create(collection=collection, based_on='default')
   yy.api_repository_update(xmlfile=colfile)
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return

#
#   Wait for the initial crawl to complete and do error checking for
#   a basic crawl.  I.e., does it crawl at all?
#   This query will return folders and documents under the
#   /testenv/test_data/law/US data folder from within sharepoint.
#
def Do_Case_1(tname=None, xx=None, yy=None, collection=None, hard_result=15666):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="story", filename="USout",
                         num=100000, odup='true')
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 1:  Totaled Results : ", urlcount
   print "CASE 1:  Counted Results : ", urlcount2
   print "CASE 1:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 1A:  Case Passed"
   else:
      print "CASE 1A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 1B:  Case Passed"
   else:
      print "CASE 1B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


#
#   Common exit routine for every routine to bail to if needed.
#
def Do_Exit_Routine(tname="not defined", total_results=0, expected_total=-1):
   print "in Do_Exit_Routine", total_results, "|", expected_total
   if (total_results == expected_total):
      print tname, ":  Test Passed"
      return 0
   
   print tname, ":  Test Failed"
   return 1





if __name__ == "__main__":

   global cmd_params

   cmd_params = {}

   fail = 1
   nokill = True


   opts, args = getopt.getopt(sys.argv[1:], "v:k", ["version=", "kill"])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a
     if o in ("-k", "--kill"):
        nokill = False


   case_res = [0]
   case_rt = [0]
   case_desc = ['CBA crawl and query']
 
   stime = etime = 0
   cstime = cetime = 0

   tname = "sp-cba"
   #cmd_params['user'] = 'administrator'
   #cmd_params['pw'] = 'Mustang5'
   collection_name = "example-metadata-test-with-cba"
   lock = simpleLock.simpleLock("mylock.123456")

   colfile = collection_name + '.xml'
   funcfile = 'oldspfunction.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for SPOC basic crawl"
   print tname, ":     Basic crawl using the new sharepoint connector"

   total_results = 0
   xx = cgi_interface.CGIINTERFACE(use_cba=True)
   yy = vapi_interface.VAPIINTERFACE(use_cba=True)

   lock.setLock()

   try:
      stime = time.time()
   
      cstime = time.time()
      if ( nokill ):
         Start_The_Crawl(tname, xx, yy, collection_name)
      else:
         Start_The_Crawl_No_Wait(tname, xx, yy, collection_name)
         i = 0
         while ( i < 5 ):
            time.sleep(45)
            yy.api_sc_crawler_stop(collection=collection_name, killit='true',
                                   subc='live')
            time.sleep(5)
            yy.api_sc_crawler_start(collection=collection_name, stype='resume')
            i += 1
         xx.wait_for_idle(collection=collection_name)
   
      print "#################################################"
   
      current_results = Do_Case_1(tname, xx, yy, collection_name, 4)
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[0] = 1
      total_results += current_results
   
   
      print tname, ":  CASE RESULTS SUMMARY"
      i = 1
      for item in case_res:
         if ( item == 1 ):
            print tname, ":     CASE", i, "PASSED,", case_desc[i - 1]
         else:
            print tname, ":     CASE", i, "FAILED,", case_desc[i - 1]
         print tname, ":        CASE", i, "Approximate run time (seconds) =", case_rt[i - 1]
         i += 1
   
   finally:
      cmd_params['listname'] = "/testenv/test_data/law/F3/465"
      cmd_params['listitem'] = None
      lock.freeLock()

   if (Do_Exit_Routine(tname, total_results, 1) == 0):
      xx.delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
      
