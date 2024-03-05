#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys, time, cgi_interface, vapi_interface
import file_interface, test_helpers
import confluence_loader
import velocityAPI, simpleLock
import os, getopt, shutil
import confluence_loader
from lxml import etree

def createUsers(userList, administrative_confluence_loader):

   tryit = administrative_confluence_loader.get_cnfl()
   for item in userList:
      print "CREATING USER", item, "with password squirrel"
      tryit.newUser(userName=item, pw='squirrel')

   return

def deleteUser(userName, administrative_confluence_loader):

   tryit = administrative_confluence_loader.get_cnfl()
   tryit.deleteUser(userName=item)

   return

def loadTheList(administrative_confluence_loader, loadlist):

   for item in loadlist:
      print "item: ", item
      administrative_confluence_loader.set_path(item)
      administrative_confluence_loader.load_a_directory()
      print "this: ", administrative_confluence_loader.get_this_pass_load_counts()

   a, b, c = administrative_confluence_loader.get_create_counts()

   print "files:", a
   print "dirs: ", b
   print "base: ", c
   print "#################################################"

   return

def initialDataLoad(administrative_confluence_loader):

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
   loadTheList(administrative_confluence_loader, initlist)

   return initlist
#
#   Wait for the initial crawl to complete and do error checking for
#   a basic crawl.  I.e., does it crawl at all?
#   This query will return folders and documents under the
#   /testenv/test_data/law/US data folder from within UCM.
#
def Run_The_Test_Case(test_help=None, hard_result=0,
                      in_query=None,
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

   print "RTTC-A/B:  Totaled Results : ", urlcount
   print "RTTC-A  :  Counted Results : ", urlcount2
   print "RTTC-B  :  Expected Results: ", hard_result

   print "-------"
   print "RTTC-A  :  Comparison of expected and total results"
   if (urlcount == hard_result):
      case_result += 1
      print "RTTC-A  :  Comparison Passed (match)"
   else:
      print "RTTC-A  :  Comparison Failed (no match)"
      for item in urllist:
         print test_name, ":  url item --", item
         doneprinting += 1

   print "-------"
   print "RTTC-B  :  Comparison of counted and total results"
   if (urlcount == urlcount2):
      case_result += 1
      print "RTTC-B  :  Comparison Passed (match)"
   else:
      print "RTTC-B  :  Comparison Failed (no match)"
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
def QueryAsUserWithPermission(administrative_confluence_loader,
                file_help, test_help, total_results):

   dumpCaseHeaderLines("Perform CASE 8: no crawl, query only")
   print "CASE EIGHT:  Query a previously crawled collection as a user"
   print "             with permission."
   print "             The query should pass.(137 query results)"

   query_user = 'him'
   query_pw = 'squirrel'
   expected_query_result = 137

   current_results = Run_The_Test_Case(test_help,
                                       expected_query_result,
                                       None, query_user, query_pw)

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results

#
##################################################################
#
#   Routines specific to Test Case 1.
#
def TestCaseOne(administrative_confluence_loader, file_help, test_help,
                hard_result, total_results):

   test_help.Start_The_Crawl()

   current_results = Run_The_Test_Case(test_help,
                                       hard_result,
                                       None, None, None)

   if ( current_results != 1 ):
      test_help.Do_Pass_Fail_Routine(total_results=total_results,
                                     expected_total=1)

   return current_results

#
##################################################################

#
##################################################################
#
#   Case named routines which call those routines that do the work.
#
def AdminUserSpaceCrawlWithoutGroupPermission(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 1: new crawl: base crawl and query")
   print "CASE ONE:  Crawl a collection as a user which has admin"
   print "           but not admin group permissions."
   print "           The crawl should fail.(0 query results)"

   expected_query_result = 0

   return  TestCaseOne(administrative_confluence_loader,
                       file_help,
                       test_help, expected_query_result,
                       total_results)

def AdminUserSpaceCrawlWithGroupPermission(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 2: new crawl: base crawl and query")
   print "CASE TWO:  Crawl a collection as a user which has admin"
   print "           AND has admin group permissions."
   print "           The crawl should succeed.(137 query results)"

   expected_query_result = 137

   #
   #   Add bubbles to a group with admin privilege
   #   Everything should now be available to bubbles.
   #
   administrative_confluence_loader.get_cnfl().addUserToGroup('bubbles', 'confluence-administrators')

   return  TestCaseOne(administrative_confluence_loader,
                       file_help,
                       test_help, expected_query_result,
                       total_results)

def AnonymousUserSpaceCrawlWithPermission(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 3: new crawl: base crawl and query")
   print "CASE THREE:  Crawl a collection as a user which is anonymous"
   print "             AND has access to the space."
   print "             The crawl should succeed.(137 query results)"

   expected_query_result = 137

   #
   #   Add anonymouns Space Permission to the space
   #
   admin_confluence_user = administrative_confluence_loader.get_cnfl()
   admin_confluence_user.addAnonymousSpacePermission('testenv', 'VIEWSPACE')

   #
   #   User 'him' should have no permissions on the site.
   #   Basically, an anonymous user equivalent.
   #
   admin_confluence_user.addSpacePermission('testenv', 'him', '')

   #
   #   Use the anonymous user
   #
   test_help.set_collection('him-collection')

   return TestCaseOne(administrative_confluence_loader,
                      file_help,
                      test_help, expected_query_result,
                      total_results)

def AnonymousUserSpaceCrawlWithoutPermission(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 4: new crawl: base crawl and query")
   print "CASE FOUR:  Crawl a collection as a user which is anonymous"
   print "            AND has no access to the space."
   print "            The crawl should succeed.(0 query results)"

   administrative_confluence_loader.get_cnfl().removeAnonymousSpacePermission('testenv', 'VIEWSPACE')

   expected_query_result = 0

   return TestCaseOne(administrative_confluence_loader,
                      file_help,
                      test_help, expected_query_result,
                      total_results)

def NormalUserCrawlingTheirOwnSpace(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 5: new crawl: base crawl and query")
   print "CASE FIVE:  Crawl a collection as a user which is the same"
   print "            user that created the crawl."
   print "            The crawl should succeed.(137 query results)"

   expected_query_result = 137

   #
   #   Get rid of admin space
   #
   administrative_confluence_loader.remove_base_space('testenv')

   #
   #   rebuild space as a user
   #
   user_with_admin_confluence_loader = confluence_loader.CONFLUENCE_LOADER(
                                      server_url=cmd_params['site'],
                                      user_name='bubbles',
                                      pw='squirrel')

   initialDataLoad(user_with_admin_confluence_loader)
   test_help.set_collection('crawl-as-user')

   return TestCaseOne(administrative_confluence_loader,
                      file_help,
                      test_help, expected_query_result,
                      total_results)


def NormalUserCrawlingAnotherUserSpace(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 6: new crawl: base crawl and query")
   print "CASE SIX:  Crawl a collection as a user which is the same"
   print "           user that created the crawl."
   print "           The crawl should succeed.(0 query results)"

   expected_query_result = 0
   test_help.set_collection('him-collection')
   #
   #   crawl the space as a different user
   #

   return TestCaseOne(administrative_confluence_loader,
                      file_help,
                      test_help, expected_query_result,
                      total_results)

def NormalUserCrawlingAnotherUserSpaceWithPermission(
                administrative_confluence_loader, file_help, test_help,
                total_results):

   dumpCaseHeaderLines("Perform CASE 7: new crawl: base crawl and query")
   print "CASE SEVEN:  Crawl a collection as a user which is the same"
   print "             user that created the crawl."
   print "             The crawl should succeed.(137 query results)"

   expected_query_result = 137
   test_help.set_collection('him-collection')

   user_with_admin_confluence_loader = confluence_loader.CONFLUENCE_LOADER(
                                      server_url=cmd_params['site'],
                                      user_name='bubbles',
                                      pw='squirrel')

   #
   #   Give the other user permission to crawl the space
   #
   user_with_admin_confluence_loader.get_cnfl().addSpacePermission('testenv', 'him', 'VIEWSPACE')

   #
   #   crawl the space as a different user with permission
   #

   return TestCaseOne(administrative_confluence_loader,
                      file_help,
                      test_help, expected_query_result,
                      total_results)



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

   collection_name = "confluence-acl-1"

   case_res = [0, 0, 0, 0, 0, 0, 0, 0]
   case_rt = [0, 0, 0, 0, 0, 0, 0, 0]

   #
   #   Case descriptions to be dumped at the end of the test with
   #   each of the case results (pass/fail)
   #
   case_desc = ['new crawl: crawling user has no permissions',
                'new crawl: crawling user is administrator',
                'new crawl: anonymous user has permission',
                'new crawl: anonymous user has no permission',
                'new crawl: user can create a space and crawl it',
                'new crawl: space created by one user and crawled by another',
                'new crawl: space created by one user and crawled by another with permission',
                'query: as user with permission on content']

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
   administrative_confluence_loader = confluence_loader.CONFLUENCE_LOADER(
                                 server_url=cmd_params['site'],
                                 user_name=cmd_params['user'],
                                 pw=cmd_params['pw'])

   try:
      #
      #   Get rid of the testenv space on confluence.  It will
      #   be recreated on the fly so it will be correct.
      #   Collection names are not relevant to the description of the test.
      #   They can be anything.
      #
      administrative_confluence_loader.remove_base_space('testenv')
      administrative_confluence_loader.remove_base_space('dietSnapple')
      administrative_confluence_loader.remove_base_space('home')
      for item in user_list:
         deleteUser(item, administrative_confluence_loader)
   except:
      print test_name, ":  Could not clean up Confluence"
      print test_name, ":  Test Failed"
      sys.exit(1)

   try:
      createUsers(user_list, administrative_confluence_loader)
   except:
      print test_name, ":  Could not create users"
      print test_name, ":  Test Failed"
      sys.exit(1)

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
      initialDataLoad(administrative_confluence_loader)
   except:
      print "Could not load initial data"
      sys.exit(1)

   try:

      #
      #   Give user bubbles admin permission.  Should have no effect
      #   because bubbles is not in a group with admin privilege.
      #
      #   Note:  Space and Page are terms relevant to confluence.
      #

      case_ct = 0
      case_res[case_ct] += AdminUserSpaceCrawlWithoutGroupPermission(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]

      case_ct += 1
      case_res[case_ct] += AdminUserSpaceCrawlWithGroupPermission(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]


      case_ct += 1
      case_res[case_ct] += AnonymousUserSpaceCrawlWithPermission(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]


      case_ct += 1
      case_res[case_ct] += AnonymousUserSpaceCrawlWithoutPermission(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]


      case_ct += 1
      case_res[case_ct] += NormalUserCrawlingTheirOwnSpace(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]

      case_ct += 1
      case_res[case_ct] += NormalUserCrawlingAnotherUserSpace(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]

      case_ct += 1
      case_res[case_ct] += NormalUserCrawlingAnotherUserSpaceWithPermission(
                                   administrative_confluence_loader,
                                   file_help, test_help, total_results)
      total_results += case_res[case_ct]

      #
      #   crawl the space as a different user with permission
      #
      case_ct += 1
      case_res[case_ct] += QueryAsUserWithPermission(
                                   administrative_confluence_loader, file_help,
                                   test_help, total_results)
      total_results += case_res[case_ct]


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
      administrative_confluence_loader.remove_base_space('testenv')
      administrative_confluence_loader.remove_base_space('dietSnapple')
      administrative_confluence_loader.remove_base_space('home')

   if (test_help.Do_Pass_Fail_Routine(total_results, 8) == 0):
      test_help.get_cgi().delete_collection(collection=collection_name, force=1)
      sys.exit(0)

   sys.exit(1)

