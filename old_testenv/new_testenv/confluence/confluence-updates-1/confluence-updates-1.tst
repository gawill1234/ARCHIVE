#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, time, cgi_interface, vapi_interface 
import file_interface, test_helpers
import confluence_loader
import velocityAPI, simpleLock
import os, getopt, shutil
import confluence_loader
from lxml import etree

#
#   Wait for the initial crawl to complete and do error checking for
#   a basic crawl.  I.e., does it crawl at all?
#   This query will return folders and documents under the
#   /testenv/test_data/law/US data folder from within UCM.
#
def Run_The_Test_Case(test_help=None, hard_result=0,
                      case_number=0, in_query=None):

   case_result = 0
   final_result = 2
   doneprinting = 0

   vapi_iface = test_help.get_vapi()
   test_name = test_help.get_test_name()

   if ( in_query is None ):
      in_query = ""
      print test_name, ":  Empty query"
   else:
      print test_name, ":  Query is", in_query

   stime = etime = 0

   print test_name, ":  Check the basic crawl data"

   stime = time.time()
   resp = vapi_iface.api_qsearch(source=test_help.get_collection(),
                                 query=in_query, filename="USout",
                                 num=100000, odup='true')
   etime = time.time()

   print test_name, ":  Approximate search time (seconds) =", etime - stime

   try:
      urlcount = vapi_iface.getTotalResults(resptree=resp)
      urlcount2 = vapi_iface.getResultUrlCount(resptree=resp)
      urllist = vapi_iface.getResultUrls(resptree=resp)
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
      for item in urllist:
         print test_name, ":  url item --", item
         doneprinting += 1

   print "-------"
   print "CASE", case_number, "RTTC-B  :  Comparison of counted and total results"
   if (urlcount == urlcount2):
      case_result += 1
      print "CASE", case_number, "RTTC-B  :  Comparison Passed (match)"
   else:
      print "CASE", case_number, "RTTC-B  :  Comparison Failed (no match)"
      if ( doneprinting == 0 ):
         for item in urllist:
            print test_name, ":  url item --", item

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
#   This is nameed TestCaseThree, but "Three" is just the first time it
#   is used.  It is a repeated use routine so CASE_STRINGS was put in to
#   output what case it is actually running on any given pass.
#
#   The case does basic queries and makes sure the correct documents actually
#   show up in the results.
#
def TestCaseThree(cnfl_load, file_help, test_help, hard_result, total_results, cmark, in_query):

   CASE_RESULT_MARKER = cmark

   CASE_STRINGS = ['ONE', 'TWO', 'THREE', 'FOUR',
                   'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN',
                   'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN',
                   'SIXTEEN', 'SEVENTEEN', 'EIGHTTEEN', 'NINETEEN', 'TWENTY',
                   'TWENTY ONE', 'TWENTY TWO', 'TWENTY THREE', 'TWENTY FOUR']

   dumpCaseHeaderLines("Perform CASE 3: new crawl: base crawl and query")

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       CASE_STRINGS[CASE_RESULT_MARKER],
                                       in_query)

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results
##################################################################
#
#   Routines specific to Test Case 2.
#
def RunCaseTwo(test_help, hard_result, total_results, case_string):

   CASE_RESULT_MARKER = 4

   test_help.Refresh_The_Crawl()

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       case_string)

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results

def CaseTwoDirectoryReset():

   try:
      shutil.rmtree('UPDATE_SPACE/DOC')
   except:
      print "UPDATE_SPACE/DOC apparently does not exist, keep going ..."

   try:
      shutil.copytree('UPDATED_DOCS/DOC', 'UPDATE_SPACE/DOC')
   except:
      print "UPDATED_DOCS/DOC apparently does not exist, shit, exiting ..."
      print tname, ":  Test Failed"
      sys.exit(1)

   return

def CaseTwoDataLoad(cnfl_load, file_help):

   #
   #   loadlist is a directory which contains files
   #   to be loaded.
   #
   full_path = os.getcwd() + '/UPDATE_SPACE/DOC'
   loadList = [full_path]

   #
   #   Files to be deleted
   #
   deleteList = ['letterhead.doc', 'California.doc', 'handbook.doc',
                 'Alarm_System.doc', 'moonews.doc']
   
   #
   #   Delete the files in the list
   #
   for item in deleteList:
      removeit = full_path + '/' + item
      cnfl_load.remove_the_file(removeit)

   #
   #   Reload the new files from the list
   #
   loadTheList(cnfl_load, file_help, loadList)

   return loadList
   
def TestCaseTwo(cnfl_load, file_help, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 2: update: add many document types, refresh, and query")

   CaseTwoDirectoryReset()
   loadlist = CaseTwoDataLoad(cnfl_load, file_help)

   return RunCaseTwo(test_help, hard_result, total_results, "TWO")

##############################
#
#   Routines for Case 21
#
def CaseTwentyOneDataLoad(cnfl_load):

   #
   #   Create a new space.
   #
   cnfl_load.build_base_space("dietSnapple",
                              "Space to replace testenv")

   #
   #   Old space and page.
   #   Space = testenv  Page = test_data
   src_path = "/testenv/test_data"

   #
   #   New space and page.
   #   Space = dietSnapple  Page = test_data
   target_path = "/dietSnapple/test_data"

   #
   #   Move the top level page from the old space to the new space
   #
   cnfl_load.move_full_page(src_path, target_path)

   #
   #   Remove the old space
   #
   cnfl_load.remove_base_space("testenv")

   return
   

def TestCaseTwentyOne(cnfl_load, file_help, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 21: move: move EVERYTHING, refresh, and query")

   loadlist = CaseTwentyOneDataLoad(cnfl_load)

   return RunCaseTwo(test_help, hard_result, total_results, "TWENTY ONE")



##############################
#
#   Routines for Case 11
#
def CaseElevenDataLoad(cnfl_load):

   src_path = os.getcwd() + '/UPDATE_SPACE/DOC'
   target_path = '/testenv/test_data/document'
   cnfl_load.move_full_page(src_path, target_path)

   return
   

def TestCaseEleven(cnfl_load, file_help, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 11: move: move full page, refresh, and query")

   loadlist = CaseElevenDataLoad(cnfl_load)

   return RunCaseTwo(test_help, hard_result, total_results, "ELEVEN")


#
##################################################################
#
#   Routines specific to Test Case 17.
#
def CaseSeventeenDataLoad(cnfl_load):

   fromDocs = ['/testenv/test_data/document/PPT/Master.ppt',
               '/testenv/test_data/document/PPT/2050.ppt',
               '/testenv/test_data/document/DOC/handbook.doc',
               '/testenv/test_data/document/DOC/California.doc',
               '/testenv/test_data/document/DOC/moonews.doc',
               '/testenv/test_data/document/XLS/test.xls']

   toDocs = ['/testenv/test_data/document/PPTX/Master.ppt',
             '/testenv/test_data/document/PPTX/2050.ppt',
             '/testenv/test_data/document/DOCX/handbook.doc',
             '/testenv/test_data/document/DOCX/California.doc',
             '/testenv/test_data/document/DOCX/moonews.doc',
             '/testenv/test_data/document/XLSX/test.xls']

   #
   #   Move the files in the fromDocs list so they
   #   reside in the toDocs area.
   #
   count = 0
   for item in fromDocs:
      cnfl_load.move_the_file(item, toDocs[count])
      count += 1

   return 

def TestCaseSeventeen(cnfl_load, file_help, test_help, hard_result, total_results):

   dumpCaseHeaderLines("Perform CASE 17: move: move documents, refresh, and query")

   CaseSeventeenDataLoad(cnfl_load)

   return RunCaseTwo(test_help, hard_result, total_results, "SEVENTEEN")
#
##################################################################
#
#   Routines specific to Test Case 1.
#
def CaseOneDataLoad(cnfl_load, file_help):

   full_path = os.getcwd() + '/UPDATE_SPACE/DOC'

   initlist = ['/testenv/test_data/document/PPT',
               '/testenv/test_data/document/PDF',
               '/testenv/test_data/document/XLS',
               full_path,
               '/testenv/test_data/document/XLSX',
               '/testenv/test_data/document/DOCX',
               '/testenv/test_data/document/PPTX']

   #
   #   Load everything from initlist into Confluence
   #
   loadTheList(cnfl_load, file_help, initlist)

   return initlist

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

def UpdateDirectoryInitializer():

   try:
      shutil.rmtree('UPDATE_SPACE/DOC')
   except:
      print "UPDATE_SPACE/DOC directory does not exist.  Continuing ..."

   try:
      shutil.copytree('/testenv/test_data/document/DOC', 'UPDATE_SPACE/DOC')
   except:
      print "UPDATE_SPACE does not exist, create and continue ..."
      try:
         os.mkdir('UPDATE_SPACE')
         shutil.copytree('/testenv/test_data/document/DOC', 'UPDATE_SPACE/DOC')
      except:
         print "Could not do required directory initialization.  Exit."
         sys.exit(-1)

   return
   
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

   cmd_params['site'] = 'http://172.16.10.81:8090/rpc/xmlrpc'
   cmd_params['user'] = 'admin'
   cmd_params['pw'] = 'Baseball123'
   cmd_params['domain'] = ''
   collection_name = "confluence-updates-1"

   hard_result = [146, 1, 0, 0, 146, 2, 1, 1, 1, 1, 146,
                  2, 1, 1, 1, 1, 146, 3, 8, 1, 146, 3, 8, 1]
   case_res = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
               0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
   case_rt = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
   case_desc = ['new crawl: add many document types, refresh, and query',
                'static: query IS GONE for one of the documents',
                'static: query BIZARRE for one of the documents',
                'static: query SPAGHETTI for one of the documents',
                'update: update 5 documents, refresh, and query',
                'update: query IS GONE for one of the updated documents',
                'update: query BIZARRE for one of the updated documents',
                'update: query SPAGHETTI for one of the updated documents',
                'update: query DONUTS for one of the updated documents',
                'update: query BEN AND JERRY for one of the updated documents',
                'move: move full page, refresh, and query',
                'move: query IS GONE for one of the updated documents',
                'move: query BIZARRE for one of the updated documents',
                'move: query SPAGHETTI for one of the updated documents',
                'move: query DONUTS for one of the updated documents',
                'move: query BEN AND JERRY for one of the updated documents',
                'move: move individual documents, refresh, and query',
                'move: query JAMES RITTER for one of the updated documents',
                'move: query JEROME PESENTI for one of the updated documents',
                'move: query SPAGHETTI for one of the updated documents',
                'move: move EVERYTHING, refresh, and query',
                'move: query JAMES RITTER for one of the updated documents',
                'move: query JEROME PESENTI for one of the updated documents',
                'move: query SPAGHETTI for one of the updated documents']
 
   stime = etime = 0
   cstime = cetime = 0

   test_name = "confluence-updates-1"
   colfile = collection_name + '.xml'

   ##############################################################
   print test_name, ":  ##################"
   print test_name, ":  INITIALIZE, Set up for Confluence crawl"
   print test_name, ":     Crawl using the new Confluence connector"
   print test_name, ":     Test crawls spaces.  Attempts to crawl"
   print test_name, ":     spaces that never existed.  Attempts to"
   print test_name, ":     recrawl spaces that have been deleted."
   print test_name, ":     Crawls spaces looking at documents additions,"
   print test_name, ":     updates, moves, and deletions.  Each of those"
   print test_name, ":     happen at document, page and space levels."
   

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
   
      UpdateDirectoryInitializer()
      #
      #   Get rid of the testenv space on confluence.  It will
      #   be recreated on the fly so it will be correct.
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
      hard_result[0] = a + b + c + 1
      hard_result[4] = hard_result[0]

      #
      ########### TWO
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "In AND Gone AND Now")
      total_results += case_res[case_ct]

      #
      ########### THREE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct, "bizarre")
      total_results += case_res[case_ct]

      #
      ########### FOUR
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "box AND spaghetti")
      total_results += case_res[case_ct]

      #
      ########### FIVE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseTwo(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results)
      total_results += case_res[case_ct]

      #
      ########### SIX
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "In AND Gone AND Now")
      total_results += case_res[case_ct]

      #
      ########### SEVEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct, "bizarre")
      total_results += case_res[case_ct]

      #
      ########### EIGHT
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "box AND spaghetti")
      total_results += case_res[case_ct]

      #
      ########### NINE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct, "Donuts")
      total_results += case_res[case_ct]

      #
      ########### TEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "Ben AND Jerry AND Ice AND Cream")
      total_results += case_res[case_ct]

      #
      ########### ELEVEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseEleven(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results)
      total_results += case_res[case_ct]

      #
      ########### TWELVE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "In AND Gone AND Now")
      total_results += case_res[case_ct]

      #
      ########### THIRTEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct, "bizarre")
      total_results += case_res[case_ct]

      #
      ########### FOURTEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "box AND spaghetti")
      total_results += case_res[case_ct]

      #
      ########### FIFTEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct, "Donuts")
      total_results += case_res[case_ct]

      #
      ########### SIXTEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "Ben AND Jerry AND Ice AND Cream")
      total_results += case_res[case_ct]

      ########### SEVENTEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseSeventeen(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results)
      total_results += case_res[case_ct]

      #
      ########### EIGHTTEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "James AND Ritter")
      total_results += case_res[case_ct]

      #
      ########### NINETEEN
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "Jerome AND Pesenti")
      total_results += case_res[case_ct]

      #
      ########### TWENTY
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "box AND spaghetti")
      total_results += case_res[case_ct]

      ########### TWENTY ONE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseTwentyOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results)
      total_results += case_res[case_ct]

      #
      ########### TWENTY TWO
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "James AND Ritter")
      total_results += case_res[case_ct]

      #
      ########### TWENTY THREE
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "Jerome AND Pesenti")
      total_results += case_res[case_ct]

      #
      ########### TWENTY FOUR
      #

      case_ct += 1
      case_res[case_ct] += TestCaseThree(cnfl_load, file_help,
                                    test_help, hard_result,
                                    total_results, case_ct,
                                    "box AND spaghetti")
      total_results += case_res[case_ct]


      print "#################################################"
      print "#################################################"

      print test_name, ":  Actual   Total Results =", total_results
      print test_name, ":  Expected Total Results = 24"

      print test_name, ":  CASE RESULTS SUMMARY"
      i = 1
      for item in case_res:
         if ( item == 1 ):
            print test_name, ":     CASE", i, "PASSED,", case_desc[i - 1]
         else:
            print test_name, ":     CASE", i, "FAILED,", case_desc[i - 1]
         i += 1

   finally:

      print test_name, ":  Do a delete of spaces testenv and home ..."
      #cnfl_load.remove_base_space('testenv')
      #cnfl_load.remove_base_space('dietSnapple')
      #cnfl_load.remove_base_space('home')

   if (test_help.Do_Pass_Fail_Routine(total_results, 24) == 0):
      test_help.get_cgi().delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
      
