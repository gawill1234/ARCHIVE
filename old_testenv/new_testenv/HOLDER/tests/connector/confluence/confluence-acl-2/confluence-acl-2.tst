#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, time, cgi_interface, vapi_interface 
import file_interface, test_helpers
import confluence_loader
import velocityAPI, simpleLock
import os, getopt, shutil
import confluence_loader
from lxml import etree

def createUsers(userList, cnfl_load):

   tryit = cnfl_load.get_cnfl()
   for item in userList:
      print "CREATING USER", item, "with password squirrel"
      tryit.newUser(userName=item, pw='squirrel')

   return

def deleteUser(userName, cnfl_load):

   tryit = cnfl_load.get_cnfl()
   tryit.deleteUser(userName=item)

   return

def loadTheList(cnfl_load, loadlist):

   for item in loadlist:
      print "item: ", item
      cnfl_load.set_path(item)
      cnfl_load.load_a_directory()
      print "this: ", cnfl_load.get_this_pass_load_counts()

   a, b, c = cnfl_load.get_create_counts()

   print "files:", a
   print "dirs: ", b
   print "base: ", c
   print "#################################################"

   return

def initialDataLoad(cnfl_load):

   initlist = ['/testenv/test_data/document/PPT',
               '/testenv/test_data/document/PDF',
               '/testenv/test_data/document/XLS',
               '/testenv/test_data/document/DOC',
               '/testenv/test_data/document/XLSX',
               '/testenv/test_data/document/DOCX',
               '/testenv/test_data/document/PPTX']

   #
   #   Load everything from initlist into Confluence
   #
   loadTheList(cnfl_load, initlist)

   return initlist
#
#   Wait for the initial crawl to complete and do error checking for
#   a basic crawl.  I.e., does it crawl at all?
#   This query will return folders and documents under the
#   /testenv/test_data/law/US data folder from within UCM.
#
def Run_The_Test_Case(test_help=None, hard_result=0,
                      case_number=0, in_query=None,
                      user=None, pw=None):

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
                                 num=100000, odup='true',
                                 user=user, passwd=pw)
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

##################################################################
#
#   Routines specific to Test Case 1.
#
def TestCaseTwo(cnfl_load, file_help, test_help,
                hard_result, total_results, case_count,
                user, pw):

   CASE_RESULT_MARKER = case_count
   dumpCaseHeaderLines("Perform CASE 1: new crawl: base crawl and query")

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       "TWO", None, user, pw)

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results

#
##################################################################
#
#   Routines specific to Test Case 1.
#
def TestCaseOne(cnfl_load, file_help, test_help,
                hard_result, total_results, case_count):

   CASE_RESULT_MARKER = case_count
   dumpCaseHeaderLines("Perform CASE 1: new crawl: base crawl and query")

   #loadlist = CaseOneDataLoad(cnfl_load, file_help)

   #hard_result[CASE_RESULT_MARKER] = a + b + c + 1

   test_help.Start_The_Crawl()

   current_results = Run_The_Test_Case(test_help,
                                       hard_result[CASE_RESULT_MARKER],
                                       "ONE", None, None, None)

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

   user_list = ['mojojojo', 'buttercup', 'bubbles', 'blossom',
                'professor_utonium', 'him', 'princess_morbucks']

   cmd_params['site'] = 'http://172.16.10.81:8090/rpc/xmlrpc'
   cmd_params['user'] = 'admin'
   cmd_params['pw'] = 'Baseball123'
   cmd_params['domain'] = ''
   collection_name = "crawl-as-user"

   hard_result = [0, 137, 137, 0, 137, 0, 137, 137]
   case_res = [0, 0, 0, 0, 0, 0, 0, 0]
   case_rt = [0, 0, 0, 0, 0, 0, 0, 0]

   case_desc = ['new crawl: crawling user has no permissions',
                'new crawl: crawling user is administrator',
                'new crawl: anonymous user has permission',
                'new crawl: anonymous use has no permission',
                'new crawl: user can create a space and crawl it',
                'new crawl: space created by one user and crawled by another',
                'new crawl: space created by one user and crawled by another with permission',
                'query: as user with permission on content',
                'query: as user with no permission on content']
 
   stime = etime = 0
   cstime = cetime = 0

   test_name = "confluence-acl-1"
   colfile = collection_name + '.xml'

   ##############################################################
   print test_name, ":  ##################"
   print test_name, ":  INITIALIZE, Set up for Confluence crawl"
   

   total_results = 0
   test_help = test_helpers.TEST_HELPERS(collection=collection_name,
                                         tname=test_name)
   file_help = file_interface.FILEINTERFACE()
   cnfl_load = confluence_loader.CONFLUENCE_LOADER(
                                 server_url=cmd_params['site'],
                                 user_name=cmd_params['user'],
                                 pw=cmd_params['pw'])

   try:
      #
      #   Get rid of the testenv space on confluence.  It will
      #   be recreated on the fly so it will be correct.
      #
      cnfl_load.remove_base_space('testenv')
      cnfl_load.remove_base_space('dietSnapple')
      cnfl_load.remove_base_space('home')
      for item in user_list:
         deleteUser(item, cnfl_load)
   except:
      print test_name, ":  Could not clean up Confluence"
      print test_name, ":  Test Failed"
      sys.exit(1)

   try:
      print "duh ..."
      createUsers(user_list, cnfl_load)
   except:
      print test_name, ":  Could not create users"
      print test_name, ":  Test Failed"
      sys.exit(1)

   #cnfl_load.set_debug(TorF=True)
   #cnfl_load.set_verbose(TorF=True)

   #lock.setLock()

   #
   #   Basic series:
   #      set/increment case number
   #      set appropriate permissions
   #      run test case
   #      increment item in pass/fail list (case_res)
   #      increment total_result based o case_res
   #
   #
   ########### ONE
   #
     
   try:
      initialDataLoad(cnfl_load)
   except:
      print "Could not load initial data"
      sys.exit(1)

   try:

      user_cnfl_load = confluence_loader.CONFLUENCE_LOADER(
                                         server_url=cmd_params['site'],
                                         user_name='bubbles',
                                         pw='squirrel')


      #
      #   Use the admin user confluence pointer
      #
      mycnfl = cnfl_load.get_cnfl()
      hercnfl = user_cnfl_load.get_cnfl()

      #
      #   Give user bubbles admin permission.  Should have no effect
      #   because bubbles is not in a group with admin privilege.
      #

      case_ct = 0
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]

      #
      #   Add bubbles to a group with admin privilege
      #   Everything should now be available to bubbles.
      #
      mycnfl.addUserToGroup('bubbles', 'confluence-administrators')
      hercnfl.watchASpace('testenv')

      case_ct += 1
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]

      #
      #   Add anonymouns Space Permission to the space
      #
      mycnfl.addAnonymousSpacePermission('testenv', 'VIEWSPACE')

      #
      #   User 'him' should have no permissions on the site.
      #   Basically, an anonymous user equivalent.
      #
      mycnfl.addSpacePermission('testenv', 'him', '')
      test_help.set_collection('him-collection')
      him_cnfl_load = confluence_loader.CONFLUENCE_LOADER(
                                         server_url=cmd_params['site'],
                                         user_name='him',
                                         pw='squirrel')
      himcnfl = him_cnfl_load.get_cnfl()

      case_ct += 1
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]


      mycnfl.removeAnonymousSpacePermission('testenv', 'VIEWSPACE')

      case_ct += 1
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]

      #
      #   Get rid of admin space
      #
      cnfl_load.remove_base_space('testenv')

      #
      #   rebuild space as a user
      #
      initialDataLoad(user_cnfl_load)
      test_help.set_collection('crawl-as-user')

      #
      #   crawl the space as a creating user
      #
      case_ct += 1
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]

      test_help.set_collection('him-collection')
      #
      #   crawl the space as a different user
      #
      case_ct += 1
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]

      #
      #   Give the other user permission to crawl the space
      #
      hercnfl.addSpacePermission('testenv', 'him', 'VIEWSPACE')

      #
      #   crawl the space as a different user with permission
      #
      case_ct += 1
      case_res[case_ct] += TestCaseOne(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct)
      total_results += case_res[case_ct]

      #
      #   crawl the space as a different user with permission
      #
      case_ct += 1
      case_res[case_ct] += TestCaseTwo(cnfl_load, file_help,
                                   test_help, hard_result,
                                   total_results, case_ct, "him", "squirrel")
      total_results += case_res[case_ct]

      #
      #   crawl the space as a different user with permission
      #
      #case_ct += 1
      #case_res[case_ct] += TestCaseTwo(cnfl_load, file_help,
      #                             test_help, hard_result,
      #                             total_results, case_ct, "mojojojo", "squirrel")
      #total_results += case_res[case_ct]


      print "#################################################"
      print "#################################################"

      print test_name, ":  Actual   Total Results =", total_results
      print test_name, ":  Expected Total Results = 8"

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

   if (test_help.Do_Pass_Fail_Routine(total_results, 8) == 0):
      test_help.get_cgi().delete_collection(collection=collection_name, force=1)
      sys.exit(0)
   
   sys.exit(1)
      
