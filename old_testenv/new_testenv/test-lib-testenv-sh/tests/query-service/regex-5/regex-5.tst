#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface


if __name__ == "__main__":

   collection_name = "regex-5"
   tname = 'regex-5'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Regular expression queries with glob wildcard enabled"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

   yy.api_repository_update(xx=xx, xmlfile="wc_options")

   cex = xx.collection_exists(collection=collection_name)

   if ( cex == 1 ):
      print tname, ":  Old collection exists.  Deleting."
      yy.api_sc_crawler_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_indexer_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_delete(xx=xx, collection=collection_name)
      cex = xx.collection_exists(collection=collection_name)
      if ( cex == 1 ):
         print tname, ":  Old collection still exists.  Trying to continue."

   if ( cex != 1 ):
      print tname, ":  Create and check the base collection"
      xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  #######################################"
   print tname, ":  Single item queries of each type to make sure"
   print tname, ":     collection exists"

   print tname, ":  Social Security Number query"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='111-22-3333',
                       filename='1ssn_url')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=0,
                      clustercount=0, perpage=1, num=1, filename='1ssn_url',
                      testname=tname)

   print tname, ":  License plate query"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ghr6369',
                       filename='1tag_url')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=0,
                      clustercount=0, perpage=1, num=1, filename='1tag_url',
                      testname=tname)

   print tname, ":  Phone number query"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='(724)555-1212',
                       filename='1phone_url')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=0,
                      clustercount=0, perpage=1, num=1, filename='1phone_url',
                      testname=tname)

   if ( cs_pass == 3 ):
      print tname, ":  Collection creation OK"
      print tname, ":  Continuing to actual regex test cases"
   else:
      print tname, ":  Collection creation failed"
      print tname, ":  Test Failed"
      sys.exit(1)
   

   print tname, ":  #######################################"
   print tname, ":  Regex queries of the collection."
   print tname, ":     Regex expressions validated with grep -E (egrep)"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":  ALL SSN query, sets with fixed counts"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[0-9]{3}-[0-9]{2}-[0-9]{4}/',
                       filename='ssn1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=6, num=6, filename='ssn1',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  ALL SSN query, sets with varied counts(+)"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[0-9]{3}-[0-9]+-[0-9]+/',
                       filename='ssn2', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=7, num=7, filename='ssn2',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":  ALL SSN query, atoms with wildcard"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/(123).(45).(6789)/',
                       filename='ssn3', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=1, num=1, filename='ssn3',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":  ALL SSN query, atoms with sets, not and varied counts"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/([0-9][^A-Z])+-[0-9]+-[0-9]+/',
                       filename='ssn4', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=7, num=7, filename='ssn4',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 5"
   print tname, ":  ALL PA TAG query, sets with counts and (?)"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[a-zA-Z]{3}-?[0-9]{4}/',
                       filename='patag1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                      clustercount=0, perpage=6, num=6, filename='patag1',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 6"
   print tname, ":  ALL PA TAG query, sets with counts, (+) and (?)"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[a-zA-Z]+-?[0-9]{4}/',
                       filename='patag2', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                      clustercount=0, perpage=6, num=6, filename='patag2',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 7"
   print tname, ":  ALL PA TAG query, sets with counts, [:alpha:], (+) and (?)"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[[:alpha:]]+-?[0-9]{4}/',
                       filename='patag3', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7,
                      clustercount=0, perpage=6, num=6, filename='patag3',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 8"
   print tname, ":  ALL PHONE query, sets with counts, and (?)"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[(]?[0-9]{3}[)-]?[0-9]{3}-?[0-9]{4}/',
                       filename='phone1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8,
                      clustercount=0, perpage=3, num=3, filename='phone1',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 9"
   print tname, ":  ALL PHONE query, sets using [:digit] with counts, and (?)"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[(]?[0-9]+[)-]?[0-9]{3}-[[:digit:]]{4}/',
                       filename='phone2', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9,
                      clustercount=0, perpage=3, num=3, filename='phone2',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 10"
   print tname, ":  ALL SSN query, sets with fixed counts"
   yy.api_qsearch(xx=xx, source=collection_name,
                  query='m/[0-9][0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9]/',
                  filename='ssn10', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10,
                      clustercount=0, perpage=6, num=6, filename='ssn10',
                      testname=tname)

   print tname, ":  #######################################"

   xx.repo_delete(elemtype="options", elemname="query-meta")

   xx.kill_all_services()

   if ( cs_pass == 13 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
