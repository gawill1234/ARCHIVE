#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#
#   Test that ACLs in sharepoint are used correctly by the crawl/query.
#   This test uses query-meta rather than the api and query-search due
#   to the fact that is difficult to impossible to get the username
#   and rights data to work correctly with the api (That is a known
#   issue).
#
#   The initial crawl is performed on the sharepoint site with limitations
#   set up.  Then two different query groups are performed.  One group is
#   for a full access user, the other from a limited access user.
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
#   Common exit routine for every routine to bail to if needed.
#
def Do_Exit_Routine(tname="not defined", total_results=0, expected_total=-1):

   if (total_results == expected_total):
      return 0

   print tname, ":  Test Failed"
   return 1

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

   print tname, ":  Set rights to use a full access user"
   srcfile = ''.join([collection, '.yes540src.xml'])
   yy.api_repository_update(xmlfile=srcfile)

   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')
   stime = time.time()
   xx.wait_for_idle(collection=collection)
   etime = time.time()

   print tname, ":  Approximate crawl time (seconds) =", etime - stime

   return


def Do_Case_1_01(tname=None, xx=None, yy=None, collection=None,
                 queryword=None, hard_result=0, hard_result2=0, filename=None):

   case_result = 0
   final_result = 2

   stime = etime = 0

   print tname, ":  Check the List -", queryword

   stime = time.time()
   #resp = yy.api_qsearch(source=collection, query=queryword,
   #                      filename=filename,
   #                      num=100000)
   xx.run_query(source=collection, query=queryword, num=100000, defoutput="querywork/MTout_1_01")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(filename="querywork/MTout_1_01")
      urlcount2 = yy.getResultUrlCount(filename="querywork/MTout_1_01")
      urllist = yy.getResultUrls(filename="querywork/MTout_1_01")
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE 1_01:  Totaled Results : ", urlcount
   print "CASE 1_01:  Counted Results : ", urlcount2
   print "CASE 1_01:  Expected Results: ", hard_result

   #for item in urllist:
   #   print item

   if (urlcount == hard_result2):
      case_result += 1
      print "CASE 1_01A:  Case Passed"
   else:
      print "CASE 1_01A:  Case Failed"

   if (hard_result == urlcount2):
      case_result += 1
      print "CASE 1_01B:  Case Passed"
   else:
      print "CASE 1_01B:  Case Failed"

   if ( case_result == final_result ):
      return 1
   else:
      #resp = yy.api_qsearch(source=collection, query=queryword,
      #                      filename="Case_1_out",
      #                      num=100000, odup="true")
      xx.run_query(source=collection, query=queryword, num=100000, defoutput="querywork/SubMTout")
      urlcount_err = yy.getTotalResults(filename="querywork/SubMTout")
      urlcount2_err = yy.getResultUrlCount(filename="querywork/SubMTout")
      urllist_err = yy.getResultUrls(filename="querywork/SubMTout")

      print "CASE 1_01_try2:  Totaled Results : ", urlcount_err
      print "CASE 1_01_try2:  Counted Results : ", urlcount2_err
      print "CASE 1_01_try2:  Expected Results: ", hard_result

      #for item in urllist:
      #   print item

      if (urlcount_err == hard_result2):
         case_result += 1
         print "CASE 1_01A_try2:  Case Passed"
      else:
         print "CASE 1_01A_try2:  Case Failed"

      if (hard_result == urlcount2_err):
         case_result += 1
         print "CASE 1_01B_try2:  Case Passed"
      else:
         print "CASE 1_01B_try2:  Case Failed"

      zz = 0
      for item in urllist_err:
         if ( isInList(item, urllist) == 0 ):
            zz += 1
            print "MISSING:", item
      print "Missing count =", zz
      return 0


def Do_Case_1(tname=None, xx=None, yy=None, collection=None, glob_results=[]):

   liststoplace = ['law/US/539', 'law/US/540', 'law/US/541']
   if ( glob_results[0] == 3528 ):
      expectedcnt = [1130, 0, 2354]
      expectedtot = [1154, 0, 2355]
   else:
      expectedcnt = [1130, 3620, 2354]
      expectedtot = [1154, 3629, 2355]
   fn = ['f539-1', 'f540-2', 'f541-3']

   case_result = 0
   hard_result = glob_results[0]
   hard_result2 = glob_results[1]
   final_result = 6

   stime = etime = 0

   print tname, ":  Query a collection with various rights enabled users."

   stime = time.time()
   print "COLLECTION:", collection
   #resp = yy.api_qsearch(source=collection, query="", filename="MTout",
   #                      num=100000, odup="true")

   xx.run_query(source=collection, query="", num=100000, defoutput="querywork/MTout")
   etime = time.time()

   print tname, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = yy.getTotalResults(filename="querywork/MTout")
      urlcount2 = yy.getResultUrlCount(filename="querywork/MTout")
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

   if (hard_result2 == urlcount2):
      case_result += 1
      print "CASE 1B:  Case Passed"
   else:
      print "CASE 1B:  Case Failed"

   mcnt = len(liststoplace)
   i = 0
   while ( i < mcnt ):
      case_result += Do_Case_1_01(tname, xx, yy, collection,
                                  liststoplace[i], expectedcnt[i],
                                  expectedtot[i],  fn[i])
      i += 1

   myq = "NOT (law/US)"
   case_result += Do_Case_1_01(tname, xx, yy, collection, myq,
                               glob_results[2], glob_results[2], 'not_q')

   print tname, ":  1 CRES =", case_result

   if ( case_result == final_result ):
      return 1
   else:
      return 0

###################################################################

if __name__ == "__main__":

   global cmd_params

   cmd_params = {}

   fail = 1
   nokill = True
   glob_results = []

   sitetype = '2010'

   opts, args = getopt.getopt(sys.argv[1:], "v:k", ["version=", "kill"])

   for o, a in opts:
     if o in ("-v", "--version"):
        sitetype = a
     if o in ("-k", "--kill"):
        nokill = False

   if ( sitetype == '2010' ):
      cmd_params['site'] = 'http://testbed18-1.test.vivisimo.com:14243/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'Mustang5'
      cmd_params['domain'] = 'sptest'
      collection_name = "sp-acl-1-2010"
      glob_results = [7157, 7122, 18]
      lock = simpleLock.simpleLock("tb18-1.14243")
   else:
      #site = 'http://testbed19-2.test.vivisimo.com:36371/'
      #cmd_params['site'] = 'http://testbed19-2.test.vivisimo.com:36371/'
      cmd_params['site'] = 'http://testbed19-2:36371/'
      cmd_params['user'] = 'administrator'
      cmd_params['pw'] = 'VolvoV70'
      cmd_params['domain'] = 'sp07test'
      collection_name = "sp-acl-1-2007"
      glob_results = [7157, 7122, 18]
      lock = simpleLock.simpleLock("tb19-2.36371")

   case_res = [0, 0]
   case_rt = [0, 0]
   case_desc = ['ACL all access user', 'ACL limited access user']
 
   stime = etime = 0
   cstime = cetime = 0

   tname = "sp-acl-1"
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Set up for SPOC basic crawl"
   print tname, ":     Crawl of sharepoint site with ACLs enabled."

   total_results = 0
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   lock.setLock()

   try:
   
      yy.api_repository_update(xmlfile="query-size.xml")
   
      print "#################################################"
   
      stime = time.time()
   
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
   
      print tname, ":  Query with a full access user"
   
      cstime = time.time()
      current_results = Do_Case_1(tname, xx, yy, collection_name, glob_results)
      cetime = time.time()
      case_rt[0] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[0] = 1
      total_results += current_results
   
      print "#################################################"
   
      print tname, ":  Switch rights to use a limited access user"
   
      srcfile = ''.join([collection_name, '.no540src.xml'])
      yy.api_repository_update(xmlfile=srcfile)
      yy.api_sc_update_config(collection=collection_name)
   
      print "#################################################"
   
      print tname, ":  Query with a limited access user"
   
      cstime = time.time()
      glob_results = [3528, 3502, 18]
      current_results = Do_Case_1(tname, xx, yy, collection_name, glob_results)
      cetime = time.time()
      case_rt[1] = cetime - cstime
      if (current_results != 1):
         Do_Exit_Routine(tname, total_results, 1)
      else:
         case_res[1] = 1
      total_results += current_results
   
      print "#################################################"
   
      yy.api_repository_del(elemtype='options', elemname='query-meta')
   
      print "#################################################"
   
      etime = time.time()
   
      print tname, ":  Actual   Total Results =", total_results
      print tname, ":  Expected Total Results = 2"
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
      lock.freeLock()
   
   if (Do_Exit_Routine(tname, total_results, 2) == 0):
      #xx.delete_collection(collection=collection_name, force=1)
      print tname, ":  Test Passed"
      sys.exit(0)
   
   print tname, ":  Test Failed"
   sys.exit(1)
      
