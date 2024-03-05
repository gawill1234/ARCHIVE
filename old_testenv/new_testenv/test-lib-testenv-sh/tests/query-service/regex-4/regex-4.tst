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

   collection_name = "regex-4"
   tname = 'regex-4'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Regular expression queries of non-alphanum characters"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

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

   print tname, ":  Number string query"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='1234567890',
                       filename='numbers')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=0,
                      clustercount=0, perpage=1, num=1, filename='numbers',
                      testname=tname)

   if ( cs_pass == 1 ):
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
   print tname, ":  Look for [] as a string"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/\[\]/',
                       filename='ssn1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      perpage=2, num=2, filename='ssn1',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  Look for () as a string"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/\(\)/',
                       filename='ssn2', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      perpage=2, num=2, filename='ssn2',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":  Look for string containing #"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/.*#.*/',
                       filename='ssn3', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      perpage=2, num=2, filename='ssn3',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":  Look for math operators (no / (divide))"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/[-\+\*=]/',
                       filename='math', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      perpage=4, num=4, filename='math',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"

   xx.kill_all_services()

   if ( cs_pass == 5 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
