#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import simpleLock
from threading import Thread
import doc_updater, getopt, time

#
#
##############################################################
#
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
   stime = time.time()
   yy.api_sc_crawler_start(collection=collection, stype='new')
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return

#
#
##############################################################
#
#
def Do_Case_1(tname=None, xx=None, yy=None, collection=None, hard_result=3):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the User Profile data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="Golf", filename="qGolf",
                         num=200000, odup="true")
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

   print tname, ":  1 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0
#
#
##############################################################
#
#
def Do_Case_2(tname=None, xx=None, yy=None, collection=None, hard_result=1):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the personal web site crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="Cray", filename="qCray",
                         num=200000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 2:  Totaled Results : ", urlcount
   print "CASE 2:  Counted Results : ", urlcount2
   print "CASE 2:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 2A:  Case Passed"
   else:
      print "CASE 2A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 2B:  Case Passed"
   else:
      print "CASE 2B:  Case Failed"

   print tname, ":  1 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0
#
#
##############################################################
#
#
if __name__ == "__main__":

   global cmd_params

   cmd_params = {}
   result_cnt = 0
   expected_cnt = 0
   current_run = 0

   sitetype = '2010'
   tname = 'sp-userdata-1'

   opts, args = getopt.getopt(sys.argv[1:], "v:", ["version="])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a

   if ( sitetype == '2010' ):
      cmd_params['site'] = site = 'http://testbed18-1.test.vivisimo.com:28347'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'Mustang5'
      cmd_params['domain'] = domain = 'sptest'
      collection_name = "sp-userdata-1-2010"
      lock = simpleLock.simpleLock("tb18-1.28347")
   else:
      cmd_params['site'] = site = 'http://testbed19-2.test.vivisimo.com:8472/'
      cmd_params['user'] = user = 'administrator'
      cmd_params['pw'] = pw = 'VolvoV70'
      cmd_params['domain'] = domain = 'sp07test'
      collection_name = "sp-userdata-1-2007"
      lock = simpleLock.simpleLock("tb19-2.8472")

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   try:
   
      print tname, ":  Start the crawl"
   
      Start_The_Crawl(tname, xx, yy, collection_name)
   
      expected_cnt += 1
      current_run = 0
      if ( sitetype == '2010' ):
         #
         #   There is an intermittent failure in 2010 where the result
         #   will sometimes be 2 and others be 3.  It's supposed to be 3.
         #
         current_run = Do_Case_1(tname, xx, yy, collection_name, 3)
      else:
         current_run = Do_Case_1(tname, xx, yy, collection_name, 1)
      if (current_run == 1):
         print tname, ":  Case Passed for User Profile data"
         result_cnt += 1
      else:
         print tname, ":  Case Failed for User Profile data"
   
      expected_cnt += 1
      current_run = 0
      current_run = Do_Case_2(tname, xx, yy, collection_name, 1)
      if (current_run == 1):
         print tname, ":  Case Passed for Personal Web site crawl"
         result_cnt += 1
      else:
         print tname, ":  Case Failed for Personal Web site crawl"
   
   finally:
      lock.freeLock()
   
if ( result_cnt == expected_cnt ):
   xx.delete_collection(collection=collection_name, force=1)
   print tname, ":  Test Passed"
   sys.exit(0)

print tname, ":  Test Failed"
sys.exit(1)
