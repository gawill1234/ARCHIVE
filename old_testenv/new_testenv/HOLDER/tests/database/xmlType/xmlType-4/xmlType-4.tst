#!/usr/bin/python
# -*- coding: utf-8 -*-


import sys, time, cgi_interface, vapi_interface 
import velocityAPI, simpleLock
import doc_updater
import os, getopt
from lxml import etree

def isInList(checkfor, thelist):

   for item in thelist:
      if ( item == checkfor ):
         return 1

   return 0

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
def Do_Case_1(tname=None, xx=None, yy=None, 
              collection=None, qry='', hard_result=15):

   case_result = 0
   #
   #   this is the base data in a newly created sharepoint teamsite for 2010.
   #
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=qry, filename="MTout",
                         num=100000)
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

   if (total_results == expected_total):
      print tname, ":  Test Passed"
      return 0
      #sys.exit(0)
   
   print tname, ":  Test Failed"
   return 1
   #sys.exit(1)

if __name__ == "__main__":

   case_res = [0, 0, 0]
   case_rt = [0, 0, 0]
   case_desc = ['empty query',
                'query of collection_name field',
                'query of collection_xml field']
   hreslist = [138, 88, 138]
   all_res = 3

   fail = 1

   stime = etime = 0
   cstime = cetime = 0

   collection_name = "xmlType_test_4"
   tname = "xmlType-4"
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for Oracle XMLType basic crawl"
   print tname, ":     Basic crawl using the new database connector."
   print tname, ":     XMLType as table"
   print tname, ":     Using custom sql seed"
   total_results = 0
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   try:
   
      print tname, ":  Set up the collection and start/refresh the crawl ..."

      stime = time.time()
      cstime = time.time()

      Start_The_Crawl(tname, xx, yy, collection_name)

      print tname, ":  ... Crawl start/refresh complete."
   
      print "#################################################"
   
      #def Do_Case_1(tname=None, xx=None, yy=None, 
      #        collection=None, qry='', hard_result=15):
      current_results = Do_Case_1(tname=tname, xx=xx, yy=yy,
                                  collection=collection_name, 
                                  hard_result=hreslist[0])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[0] = 1
      total_results += current_results

      current_results = Do_Case_1(tname=tname, xx=xx, yy=yy, qry="samba",
                                  collection=collection_name, 
                                  hard_result=hreslist[1])
      cetime = time.time()
      case_rt[1] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[1] = 1
      total_results += current_results

      current_results = Do_Case_1(tname=tname, xx=xx, yy=yy, qry="collection",
                                  collection=collection_name, 
                                  hard_result=hreslist[2])
      cetime = time.time()
      case_rt[2] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[2] = 1
      total_results += current_results
   
      print "#################################################"
   
      etime = time.time()
   
      print tname, ":  Actual   Total Results =", total_results
      print tname, ":  Expected Total Results = ", all_res
      print tname, ":  Approximate test run time (seconds) =", etime - stime
   
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
      print "ALL DONE!!!!"
   
   if (Do_Exit_Routine(tname, total_results, all_res) == 0):
      xx.delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
