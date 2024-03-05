#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, time
import file_interface, test_helpers
import confluence_loader
import os, getopt
from lxml import etree

#
#   Wait for the initial crawl to complete and do error checking for
#   a basic crawl.  I.e., does it crawl at all?
#   This query will return folders and documents under the
#   /testenv/test_data/law/US data folder from within UCM.
#
def Run_The_Test_Case(test_help=None, hard_result=0, case_number=0):

   case_result = 0
   final_result = 2

   vapi_iface = test_help.get_vapi()

   stime = etime = 0

   print test_name, ":  Check the basic crawl data"

   stime = time.time()
   resp = vapi_iface.api_qsearch(source=test_help.get_collection(),
                                 query="", filename="USout",
                                 num=100000, odup='true')
   etime = time.time()

   print test_name, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = vapi_iface.getTotalResults(resptree=resp)
      urlcount2 = vapi_iface.getResultUrlCount(resptree=resp)
   except:
      urlcount = 0
      urlcount2 = 0

   print "CASE", case_number, "RTTC-A/B:  Totaled Results : ", urlcount
   print "CASE", case_number, "RTTC-A  :  Counted Results : ", urlcount2
   print "CASE", case_number, "RTTC-B  :  Expected Results: ", hard_result

   print "-------"
   print "CASE", case_number, "RTTC-A  :  Comparison of expected and total results"
   if (urlcount == hard_result):
      case_result += 1
      print "CASE", case_number, "RTTC-A  :  Comparison Passed (match)"
   else:
      print "CASE", case_number, "RTTC-A  :  Comparison Failed (no match)"

   print "-------"
   print "CASE", case_number, "RTTC-B  :  Comparison of counted and total results"
   if (urlcount == urlcount2):
      case_result += 1
      print "CASE", case_number, "RTTC-B  :  Comparison Passed (match)"
   else:
      print "CASE", case_number, "RTTC-B  :  Comparison Failed (no match)"

   if ( case_result == final_result ):
      return 1
   else:
      return 0

def dumpCaseHeaderLines(dumpstring):

   print "################################################################"
   print "################################################################"
   print "################################################################"
   print "################################################################"
   print dumpstring
   print "             ++++++++++++++++++++++++++++++++++++"

   return

def loadTheList(cnfl_load, file_help, loadlist):

   for item in loadlist:
      print "item: ", item
      cnfl_load.set_path(item)
      cnfl_load.load_a_directory()
      print "this: ", cnfl_load.get_this_pass_load_counts()

   print "#################################################"

   return


#
##################################################################
#
#   Routines specific to Test Case 7.
#
def CaseSevenDataLoad(cnfl_load, file_help):

   loadList = ['/testenv/test_data/document/PPT',
               '/testenv/test_data/law/US/2',
               '/testenv/test_data/law/US/19',
               '/testenv/test_data/law/US/412']

   loadTheList(cnfl_load, file_help, loadList)

   tryit = cnfl_load.get_cnfl()
   tryit.commentExistingPage('testenv', 'test_data',
                             'page test_data has been updated(seven)')
   tryit.commentExistingPage('testenv', 'law',
                             'page law has been updated(seven)')
   tryit.commentExistingPage('testenv', 'document',
                             'page document has been updated(seven)')

   return loadList
   

def TestCaseSeven(cnfl_load, file_help, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 4: update: add many pages, refresh, and query")
   CaseSevenDataLoad(cnfl_load, file_help)

   CASE_RESULT_MARKER = 3
   test_help.Refresh_The_Crawl()

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       "SEVEN")

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results

#
##################################################################
#
#   Routines specific for Test Case 3.  Case 3 is identical to 2
#   except that it does no updates.  Only a refresh.  That being the
#   case, it reuses the test case 2 routines where applicable.
#
def TestCaseThree(cnfl_load, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 3: stable: on a stable collection, refresh, and query")
   tryit = cnfl_load.get_cnfl()
   tryit.commentExistingPage('testenv', 'test_data', 'page has been updated(three)')

   return RunCaseTwo(test_help, hard_result, total_results, "THREE")


#
##################################################################
#
#   Routines specific to Test Case 2.
#
def RunCaseTwo(test_help, hard_result, total_results, case_string):

   CASE_RESULT_MARKER = 1

   test_help.Refresh_The_Crawl()

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       case_string)

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results

def CaseTwoDataLoad(cnfl_load, file_help):

   loadList = ['/testenv/test_data/document/PPT',
               '/testenv/test_data/document/DOC',
               '/testenv/test_data/document/XLS',
               '/testenv/test_data/document/PDF',
               '/testenv/test_data/document/XLSX',
               '/testenv/test_data/document/PPTX',
               '/testenv/test_data/document/DOCX']

   loadTheList(cnfl_load, file_help, loadList)

   tryit = cnfl_load.get_cnfl()
   tryit.commentExistingPage('testenv', 'test_data', 'page has been updated')

   return loadList
   
def TestCaseTwo(cnfl_load, file_help, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 2: update: add many document types, refresh, and query")
   loadlist = CaseTwoDataLoad(cnfl_load, file_help)

   return RunCaseTwo(test_help, hard_result, total_results, "TWO")


#
##################################################################
#
#   Routines specific to Test Case 1.
#
def CaseOneDataLoad(cnfl_load, file_help):

   print "Initialize main load list"
   loadlist = []
   x = 1
   while ( x < 10 ):
      swiffer = '/testenv/test_data/law/US/' + '%s' % x
      x += 1
      if ( file_help.pathNameExists( swiffer ) ):
         print "Loadable directory:", swiffer
         loadlist.append(swiffer)

   loadTheList(cnfl_load, file_help, loadlist)

   return loadlist

def TestCaseOne(cnfl_load, file_help, test_help, hard_result, total_results):

   CASE_RESULT_MARKER = 0
   dumpCaseHeaderLines("Perform CASE 1: new crawl: base crawl and query")

   loadlist = CaseOneDataLoad(cnfl_load, file_help)
   a, b, c = cnfl_load.get_create_counts()

   print "files:", a
   print "dirs: ", b
   print "base: ", c
   hard_result[CASE_RESULT_MARKER] = a + b + c + 1

   test_help.Start_The_Crawl()

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       "ONE")

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results
   
#
##################################################################


if __name__ == "__main__":

   global cmd_params

   cmd_params = {}

   fail = 1
   nokill = True

   opts, args = getopt.getopt(sys.argv[1:], "k", ["version=", "kill"])

   for o, a in opts:
     if o in ("-k", "--kill"):
        nokill = False

   hard_result = [368, 502, 502, 592]

   cmd_params['site'] = 'http://172.16.10.81:8090/rpc/xmlrpc'
   cmd_params['user'] = 'admin'
   cmd_params['pw'] = 'Baseball123'
   cmd_params['domain'] = ''
   collection_name = "confluence-partial-1"

   case_res = [0, 0, 0, 0]
   case_rt = [0, 0, 0, 0]
   case_desc = ['new crawl: base crawl and query',
                'update: add many document types, refresh, and query',
                'stable: on a stable collection, refresh, and query',
                'update: add many pages, refresh, and query']
 
   stime = etime = 0
   cstime = cetime = 0

   test_name = "confluence-partial-1"
   colfile = collection_name + '.xml'

   ##############################################################
   print test_name, ":  ##################"
   print test_name, ":  INITIALIZE, Set up for UCM basic crawl"
   print test_name, ":     Basic crawl using the new Oracle UCM connector"

   total_results = 0
   test_help = test_helpers.TEST_HELPERS(collection=collection_name,
                                         tname=test_name)
   file_help = file_interface.FILEINTERFACE()
   cnfl_load = confluence_loader.CONFLUENCE_LOADER(
                                 server_url=cmd_params['site'],
                                 user_name=cmd_params['user'],
                                 pw=cmd_params['pw'])

   #cnfl_load.set_debug(TorF=True)
   #cnfl_load.set_verbose(TorF=True)


   #lock.setLock()

   try:
   
      #
      #   Get rid of the testenv space on confluence.  It will
      #   be recreated on the fly so it will be correct.
      #
      #   It also gets rid of spaces created by other tests.  Just to
      #   be safe.
      #
      cnfl_load.remove_base_space('testenv')
      cnfl_load.remove_base_space('dietSnapple')
      cnfl_load.remove_base_space('home')

      #
      #   Basic series:
      #      set/increment case number
      #      run test case
      #      increment item in pass/fail list (case_res)
      #      increment total_result based o case_res
      #
      #
      ########### ONE
      #
     
      case_ct = 0
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results)
      total_results += case_res[case_ct]
      a, b, c = cnfl_load.get_create_counts()
      #
      #   This resets the expected values so that if a new directory
      #   turns up in the loaded directory, it will still be correct.
      #
      hard_result[0] = a + b + c + 1
      hard_result[1] = hard_result[0] + 134
      hard_result[2] = hard_result[1]
      hard_result[3] = hard_result[2] + 90

      #
      ########### TWO
      #

      case_ct += 1
      case_res[case_ct] += TestCaseTwo(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results)
      total_results += case_res[case_ct]

      #
      ########### THREE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, test_help, hard_result, total_results)
      total_results += case_res[case_ct]

      #
      ########### SEVEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseSeven(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results)
      total_results += case_res[case_ct]


      print "#################################################"
      print "#################################################"

      print test_name, ":  Actual   Total Results =", total_results
      print test_name, ":  Expected Total Results = 4"

      print test_name, ":  CASE RESULTS SUMMARY"
      i = 1
      for item in case_res:
         if ( item == 1 ):
            print test_name, ":     CASE", i, "PASSED,", case_desc[i - 1]
         else:
            print test_name, ":     CASE", i, "FAILED,", case_desc[i - 1]
         i += 1

   finally:

      print "should do a delete of space testenv ..."
      cnfl_load.remove_base_space('testenv')

   if (test_help.Do_Pass_Fail_Routine(total_results, 4, False) == 0):
      test_help.get_cgi().delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
      
