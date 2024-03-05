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

   collection_name = "regex-6"
   tname = 'regex-6'

   colfile = ''.join([collection_name, '.xml'])
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Regular expression queries of large numbers"
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
                      clustercount=0, perpage=2, num=2, filename='numbers',
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
   print tname, ":     11633[0-9]{20}"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/11633[0-9]{20}/',
                       filename='ssn1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      perpage=3, num=3, filename='ssn1',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":     90193[0-9]+"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/90193[0-9]+/',
                       filename='ssn2', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      perpage=3, num=3, filename='ssn2',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":     1163320632970866214924362"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='m/1163320632970866214924362/',
                       filename='ssn3', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      perpage=3, num=3, filename='ssn3',
                      clustercount=0, testname=tname)

   print tname, ":  #######################################"

   xx.kill_all_services()

   if ( cs_pass == 4 ):
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
