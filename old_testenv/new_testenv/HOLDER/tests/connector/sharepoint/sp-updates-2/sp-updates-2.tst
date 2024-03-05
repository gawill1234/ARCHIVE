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
def Do_Case_1(tname=None, xx=None, yy=None, collection=None, hard_result=15):

   case_result = 0
   #
   #   this is the base data in a newly created sharepoint teamsite for 2010.
   #
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the basic crawl data"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
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

def Do_Case_4(tname=None, xx=None, yy=None, collection=None, hard_result=128):

   case_result = 0
   final_result = 3

   stime = etime = 0

   print tname, ":  Update add one new docuemnt in a new folder and refresh crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="Four_out",
                         num=100000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 4:  Totaled Results : ", urlcount
   print "CASE 4:  Counted Results : ", urlcount2
   print "CASE 4:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 4A:  Case Passed"
   else:
      print "CASE 4A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 4B:  Case Passed"
   else:
      print "CASE 4B:  Case Failed"

   if ( collection == 'sp-updates-2-oldconn' ):
      expres = 1
   else:
      expres = 2

   case_result += Do_Case_3_01(tname, xx, yy, collection,
                               "law/F3/27", expres)

   print tname, ":  4 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_4(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   cmd_params['listname'] = "/testenv/test_data/law/F3"
   cmd_params['listitem'] = "27"
   print tname, ":  createFolder, ", cmd_params['listname'], cmd_params['listitem']
   doc_updater.createFolder(**cmd_params)
   cmd_params['listname'] = "/testenv/test_data/law/F3/27"
   cmd_params['listitem'] = "/testenv/test_data/law/F3/27/27.F3d.90.93-5145.html"
   print tname, ":  createDocument, ", cmd_params['listname'], cmd_params['listitem']
   doc_updater.createDocument(**cmd_params)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_3_01(tname=None, xx=None, yy=None, collection=None,
                 queryword=None, hard_result=0):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="list_elem_out",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 3_01:  Totaled Results : ", urlcount
   print "CASE 3_01:  Counted Results : ", urlcount2
   print "CASE 3_01:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 3_01A:  Case Passed"
   else:
      print "CASE 3_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 3_01B:  Case Passed"
   else:
      print "CASE 3_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Do_Case_3(tname=None, xx=None, yy=None, collection=None, hard_result=126):

   liststoplace = ['law/US/26', 'law/F3/465', 'law/F2/643', 'law/US/360']
   if ( collection == 'sp-updates-2-oldconn' ):
      expectedcnt = [56, 0, 0, 47]
   else:
      expectedcnt = [57, 0, 0, 48]

   case_result = 0
   final_result = 6

   stime = etime = 0

   print tname, ":  Update(delete) folders and documents and refresh crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000, odup='true')
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 3:  Totaled Results : ", urlcount
   print "CASE 3:  Counted Results : ", urlcount2
   print "CASE 3:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 3A:  Case Passed"
   else:
      print "CASE 3A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 3B:  Case Passed"
   else:
      print "CASE 3B:  Case Failed"

   mcnt = len(liststoplace)
   i = 0
   while ( i < mcnt ):
      case_result += Do_Case_3_01(tname, xx, yy, collection,
                                  liststoplace[i], expectedcnt[i])
      i += 1

   print tname, ":  3 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_3(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   mountpoints = ["/testenv/test_data/law/F3/465",
                  "/testenv/test_data/law/F2/643"]

   stime = etime = 0

   print tname, ":  Do a refresh and check the data"
   print tname, ":  Add data to the crawled site for a refresh"

   for item in mountpoints:
      cmd_params['listname'] = item
      cmd_params['listitem'] = None
      print tname, ":  deleteTree, ", cmd_params['listname']
      doc_updater.deleteTree(**cmd_params)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_2_01(tname=None, xx=None, yy=None, collection=None,
                 queryword=None, hard_result=0):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="list_elem_out",
                         num=100000)
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 2_01:  Totaled Results : ", urlcount
   print "CASE 2_01:  Counted Results : ", urlcount2
   print "CASE 2_01:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 2_01A:  Case Passed"
   else:
      print "CASE 2_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 2_01B:  Case Passed"
   else:
      print "CASE 2_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      return 0


def Do_Case_2(tname=None, xx=None, yy=None, collection=None, hard_result=373):

   liststoplace = ['law/US/26', 'law/F3/465', 'law/F2/643', 'law/US/360']
   #
   #   The old verison of sharepoint does not return the directory
   #   which as the docs in it.
   #
   if ( collection == 'sp-updates-2-oldconn' ):
      expectedcnt = [56, 53, 192, 47]
   else:
      expectedcnt = [57, 54, 193, 48]

   case_result = 0
   #
   #   this is the base data in a newly created sharepoint teamsite for 2010.
   #
   final_result = 6

   stime = etime = 0

   print tname, ":  Update(add) directory/folders with docs and re-crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000, odup="true")
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

   mcnt = len(liststoplace)
   i = 0
   while ( i < mcnt ):
      case_result += Do_Case_2_01(tname, xx, yy, collection,
                                  liststoplace[i], expectedcnt[i])
      i += 1

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_2(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   mountpoints = ["/testenv/test_data/law/F3/465",
                  "/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/360",
                  "/testenv/test_data/law/F2/643"]

   stime = etime = 0

   print tname, ":  Do a refresh and check the data"
   print tname, ":  Add data to the crawled site for a refresh"

   for item in mountpoints:
      cmd_params['listname'] = item
      cmd_params['listitem'] = None
      print tname, ":  createTree, ", cmd_params['listname']
      doc_updater.createTree(**cmd_params)

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_5(tname=None, xx=None, yy=None, collection=None, hard_result=128):

   liststoplace = ['law/US/26', 'law/F3/465', 'law/F2/643', 'law/US/360']
   if ( collection == 'sp-updates-2-oldconn' ):
      expectedcnt = [56, 0, 0, 47]
   else:
      expectedcnt = [57, 0, 0, 48]

   case_result = 0
   final_result = 6

   stime = etime = 0

   print tname, ":  Update (delete and re-add) several documents and refresh crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 5:  Totaled Results : ", urlcount
   print "CASE 5:  Counted Results : ", urlcount2
   print "CASE 5:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 5A:  Case Passed"
   else:
      print "CASE 5A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 5B:  Case Passed"
   else:
      print "CASE 5B:  Case Failed"

   mcnt = len(liststoplace)
   i = 0
   while ( i < mcnt ):
      case_result += Do_Case_3_01(tname, xx, yy, collection,
                                  liststoplace[i], expectedcnt[i])
      i += 1

   print tname, ":  5 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_5(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   mountpoints = ["/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/360",
                  "/testenv/test_data/law/US/360"]
   docstodeladd = ["26.US.1.html", "26.US.37.html", "26.US.562.html",
                   "360.US.219.157.html", "360.US.55.406.447.html"]

   stime = etime = 0

   print tname, ":  Do a refresh and check the data"
   print tname, ":  Delete and Add data to the crawled site for a refresh"

   mntlen = len(mountpoints)
   doclen = len(docstodeladd)
   if ( doclen < mntlen ):
      mntlen = doclen
   i = 0
   while ( i < mntlen ):
      cmd_params['listname'] = mountpoints[i]
      cmd_params['listitem'] = docstodeladd[i]
      print tname, ":  deleteDocument, ", cmd_params['listname'], cmd_params['listitem']
      doc_updater.deleteDocument(**cmd_params)
      cmd_params['listitem'] = mountpoints[i] + "/" + docstodeladd[i]
      print tname, ":  createDocument, ", cmd_params['listname'], cmd_params['listitem']
      doc_updater.createDocument(**cmd_params)
      i += 1

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_6_01(tname=None, xx=None, yy=None, collection=None,
                 queryword=None, hard_result=0):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="Case_6_out",
                         num=100000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
      urllist = yy.getResultUrls(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 6_01:  Totaled Results : ", urlcount
   print "CASE 6_01:  Counted Results : ", urlcount2
   print "CASE 6_01:  Expected Results: ", hard_result

   #for item in urllist:
   #   print item

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 6_01A:  Case Passed"
   else:
      print "CASE 6_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 6_01B:  Case Passed"
   else:
      print "CASE 6_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      resp = yy.api_qsearch(source=collection, query=queryword,
                            filename="Case_6_out",
                            num=100000, odup="true")
      urllist_err = yy.getResultUrls(resptree=resp)
      for item in urllist_err:
         if ( isInList(item, urllist) == 0 ):
            print "MISSING:", item
      return 0


def Do_Case_6(tname=None, xx=None, yy=None, collection=None, hard_result=133):

   liststoplace = ['law/US/26', 'law/F3/465', 
                   'law/F2/643', 'law/US/360', 'law/F3/27']

   if ( collection == 'sp-updates-2-oldconn' ):
      expectedcnt = [56, 0, 0, 47, 1]
   else:
      expectedcnt = [60, 0, 0, 50, 2]

   final_result = 8
   case_result = 0

   stime = etime = 0

   print tname, ":  Update (delete and re-add) several documents and refresh crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 6:  Totaled Results : ", urlcount
   print "CASE 6:  Counted Results : ", urlcount2
   print "CASE 6:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 6A:  Case Passed"
   else:
      print "CASE 6A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 6B:  Case Passed"
   else:
      print "CASE 6B:  Case Failed"

   mcnt = len(liststoplace)
   i = 0
   while ( i < mcnt ):
      case_result += Do_Case_6_01(tname, xx, yy, collection,
                                  liststoplace[i], expectedcnt[i])
      i += 1

   myq = "NOT (law/US OR law/F2 OR law/F3)"
   if ( collection == 'sp-updates-2-2010' ):
      case_result += Do_Case_6_01(tname, xx, yy, collection, myq, 18)
   elif ( collection == 'sp-updates-2-2007' ):
      case_result += Do_Case_6_01(tname, xx, yy, collection, myq, 8)
   else:
      case_result += Do_Case_6_01(tname, xx, yy, collection, myq, 6)

   print tname, ":  6 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_6(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   mountpoints = ["/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/26",
                  "/testenv/test_data/law/US/360",
                  "/testenv/test_data/law/US/360"]
   newpoints = ["26_A", "26_B", "26_C", "360_A", "360_B"]
   docstodeladd = ["26.US.1.html", "26.US.37.html", "26.US.562.html",
                   "360.US.219.157.html", "360.US.55.406.447.html"]

   stime = etime = 0

   print tname, ":  Do a refresh and check the data"
   print tname, ":  Delete and Add data to the crawled site for a refresh"

   mntlen = len(mountpoints)
   doclen = len(docstodeladd)
   if ( doclen < mntlen ):
      mntlen = doclen
   i = 0
   while ( i < mntlen ):
      cmd_params['listname'] = mountpoints[i]
      cmd_params['listitem'] = docstodeladd[i]
      print tname, ":  deleteDocument, ", cmd_params['listname'], cmd_params['listitem']
      doc_updater.deleteDocument(**cmd_params)
      cmd_params['listname'] = "/testenv/test_data/law/US"
      cmd_params['listitem'] = newpoints[i]
      print tname, ":  createFolder, ", cmd_params['listname'], cmd_params['listitem']
      doc_updater.createFolder(**cmd_params)
      cmd_params['listname'] = "/testenv/test_data/law/US" + "/" + newpoints[i]
      cmd_params['listitem'] = mountpoints[i] + "/" + docstodeladd[i]
      print tname, ":  createDocument, ", cmd_params['listname'], cmd_params['listitem']
      doc_updater.createDocument(**cmd_params)
      i += 1

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

   return 0

def Do_Case_7_01(tname=None, xx=None, yy=None, collection=None,
                 queryword=None, hard_result=0, expurl=None):

   case_result = 0
   final_result = 3

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query=queryword,
                         filename="Case_7_out",
                         num=100000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
      urllist = yy.getResultUrls(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 7_01:  Totaled Results : ", urlcount
   print "CASE 7_01:  Counted Results : ", urlcount2
   print "CASE 7_01:  Expected Results: ", hard_result

   print expurl
   myfile = os.path.basename(expurl)
   for item in urllist:
      ufile = os.path.basename(item)
      print item
      if ( ufile != myfile ):
         print "CASE 7_01MAIN:  BARF, Case Failed"
      else:
         case_result += 1
         print "CASE 7_01MAIN:  Held it together, Case Passed"

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 7_01A:  Case Passed"
   else:
      print "CASE 7_01A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 7_01B:  Case Passed"
   else:
      print "CASE 7_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      resp = yy.api_qsearch(source=collection, query=queryword,
                            filename="Case_7_out",
                            num=100000, odup="true")
      urllist_err = yy.getResultUrls(resptree=resp)
      for item in urllist_err:
         if ( isInList(item, urllist) == 0 ):
            print "MISSING:", item
      return 0


def Do_Case_7(tname=None, xx=None, yy=None, collection=None, hard_result=133):

   expfile = ["/testenv/test_data/law/US/26/26.US.110.html",
              "/testenv/test_data/law/US/26_C/26.US.562.html",
              "/testenv/test_data/law/US/360/360.US.470.435.436.437.html",
              "/testenv/test_data/law/US/360/360.US.712.2.3.4.15.html"]

   querylist = ['squirrels', 'rabbit', 'deer AND tulips', 'capybara']

   expectedcnt = [1, 1, 1, 1]

   case_result = 0
   final_result = 6

   stime = etime = 0

   print tname, ":  Update (inplace) several documents and refresh crawl"

   stime = time.time()
   resp = yy.api_qsearch(source=collection, query="", filename="MTout",
                         num=100000, odup="true")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(resptree=resp)
      urlcount2 = yy.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 7:  Totaled Results : ", urlcount
   print "CASE 7:  Counted Results : ", urlcount2
   print "CASE 7:  Expected Results: ", hard_result

   if (urlcount == hard_result):
      case_result += 1
      print "CASE 7A:  Case Passed"
   else:
      print "CASE 7A:  Case Failed"

   if (urlcount == urlcount2):
      case_result += 1
      print "CASE 7B:  Case Passed"
   else:
      print "CASE 7B:  Case Failed"

   i = 0
   for item in querylist:
      case_result += Do_Case_7_01(tname, xx, yy, collection,
                                  item, expectedcnt[i],
                                  expfile[i])
      i += 1

   print tname, ":  7 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def Update_For_Case_7(tname=None, xx=None, yy=None, collection=None):

   global cmd_params

   mountpoints = ["/testenv/test_data/law/US/26/26.US.110.html",
                  "/testenv/test_data/law/US/26_C/26.US.562.html",
                  "/testenv/test_data/law/US/360/360.US.470.435.436.437.html",
                  "/testenv/test_data/law/US/360/360.US.712.2.3.4.15.html"]
   docstodeladd = ["update_docs/26.US.110.html", "update_docs/26.US.562.html",
                   "update_docs/360.US.470.435.436.437.html",
                   "update_docs//360.US.712.2.3.4.15.html"]

   stime = etime = 0

   print tname, ":  Do a refresh and check the data"
   print tname, ":  Update data inplace and crawl site for a refresh"

   mntlen = len(mountpoints)
   doclen = len(docstodeladd)
   if ( doclen < mntlen ):
      mntlen = doclen

   i = 0
   while ( i < mntlen ):
      cmd_params['listname'] = mountpoints[i]
      cmd_params['listitem'] = docstodeladd[i]
      print tname, ":  updateDocument, ", cmd_params['listname'], cmd_params['listitem']
      doc_updater.updateDocument(**cmd_params)
      i += 1

   yy.api_sc_crawler_start(collection=collection, stype='refresh-inplace')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate refresh time (seconds) =", etime - stime

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

   global cmd_params

   fail = 1
   cmd_params = {}
   funcfile = 'oldspfunction.xml'

   sitetype = '2010'

   opts, args = getopt.getopt(sys.argv[1:], "v:", ["version="])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a

   if ( sitetype == '2010' ):
      hreslist = [15, 373, 126, 128, 128, 133, 133]
      cmd_params['site'] = 'http://testbed18-1.test.vivisimo.com:47401/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'Mustang5'
      cmd_params['domain'] = 'sptest'
      collection_name = "sp-updates-2-2010"
      lock = simpleLock.simpleLock("tb18-1.47401")
   elif ( sitetype == '2007' ):
      #site = 'http://testbed19-2.test.vivisimo.com:36436/'
      hreslist = [5, 363, 116, 118, 118, 123, 123]
      cmd_params['site'] = 'http://testbed19-2:36436/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'VolvoV70'
      cmd_params['domain'] = 'sp07test'
      collection_name = "sp-updates-2-2007"
      lock = simpleLock.simpleLock("tb19-2.36436")
   else:
      hreslist = [5, 354, 109, 110, 110, 110, 110]
      cmd_params['site'] = 'http://testbed19-2:36436/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'VolvoV70'
      cmd_params['domain'] = 'sp07test'
      collection_name = "sp-updates-2-oldconn"
      lock = simpleLock.simpleLock("tb19-2.36436")

   case_res = [0,0,0,0,0,0, 0]
   case_rt = [0,0,0,0,0,0, 0]
   case_desc = ['base crawl/query', 'update (add) crawl/query',
                'update (delete) crawl/query', 
                'update (add one) crawl/query',
                'update (delete/re-add) crawl/query',
                'update (delete/re-add, new location) crawl/query',
                'update documents inplace and crawl/query']
 
   stime = etime = 0
   cstime = cetime = 0

   tname = "sp-updates-2"
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for SPOC basic crawl"
   print tname, ":     Basic crawl using the new sharepoint connector"
   total_results = 0
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   try:
   
      if ( collection_name == 'sp-updates-2-oldconn' ):
         yy.api_repository_update(xmlfile=funcfile)
   
      doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
   
      stime = time.time()
   
      cstime = time.time()
      Start_The_Crawl(tname, xx, yy, collection_name)
   
      print "#################################################"
   
      current_results = Do_Case_1(tname, xx, yy, collection_name, hreslist[0])
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[0] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_2(tname, xx, yy, collection_name)
      current_results = Do_Case_2(tname, xx, yy, collection_name, hreslist[1])
      cetime = time.time()
      case_rt[1] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 2)
      else:
         case_res[1] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_3(tname, xx, yy, collection_name)
      current_results = Do_Case_3(tname, xx, yy, collection_name, hreslist[2])
      cetime = time.time()
      case_rt[2] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 4)
      else:
         case_res[2] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_4(tname, xx, yy, collection_name)
      current_results = Do_Case_4(tname, xx, yy, collection_name, hreslist[3])
      cetime = time.time()
      case_rt[3] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 4)
      else:
         case_res[3] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_5(tname, xx, yy, collection_name)
      current_results = Do_Case_5(tname, xx, yy, collection_name, hreslist[4])
      cetime = time.time()
      case_rt[4] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 4)
      else:
         case_res[4] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_6(tname, xx, yy, collection_name)
      current_results = Do_Case_6(tname, xx, yy, collection_name, hreslist[5])
      cetime = time.time()
      case_rt[5] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 4)
      else:
         case_res[5] = 1
      total_results += current_results
   
      print "#################################################"
   
      cstime = time.time()
      Update_For_Case_7(tname, xx, yy, collection_name)
      current_results = Do_Case_7(tname, xx, yy, collection_name, hreslist[6])
      cetime = time.time()
      case_rt[6] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 4)
      else:
         case_res[6] = 1
      total_results += current_results
   
      print "#################################################"
   
      etime = time.time()
      print tname, ":  Actual   Total Results =", total_results
      print tname, ":  Expected Total Results = 7"
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
      doc_updater.flush_all_data(tname, xx, yy, 0, **cmd_params)
      lock.freeLock()
   
   if (Do_Exit_Routine(tname, total_results, 7) == 0):
      xx.delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
