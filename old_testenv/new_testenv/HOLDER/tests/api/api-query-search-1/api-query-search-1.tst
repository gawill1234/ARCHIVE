#!/usr/bin/python

#
#   Test of the api
#   This is a basic test of query-search.  It uses
#   the federated source BBCNews for all of the queries so
#   it only looks to make sure numbers come back
#   (i.e., a query was actually done).
#

import sys, time, cgi_interface, vapi_interface

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   ##############################################################
   print "api-query-search-1:  ##################"
   print "api-query-search-1:  INITIALIZE"
   print "api-query-search-1:  query-search (test 1)"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   thebeginning = time.time()

   ##############################################################
   print "api-query-search-1:  ##################"
   print "api-query-search-1:  TEST CASES BEGIN"


   print "api-query-search-1:  ##################"
   print "api-query-search-1:  CASE 1, DEFAULTS"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='BBCNews', query='iraq',
                 cluster='false', fetchtimeout=10000, num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=10, num=10)
   print "api-query-search-1:  ##################"


   print "api-query-search-1:  ##################"
   print "api-query-search-1:  CASE 2, modified retrieval count"
   print "api-query-search-1:          clustering enabled, default"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='BBCNews', query='iraq',
                 cluster='true', clustercount=10, fetchtimeout=10000,
                 num=500, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=10,
                                          perpage=10, num=500)
   print "api-query-search-1:  ##################"

   print "api-query-search-1:  ##################"
   print "api-query-search-1:  CASE 3, modified retrieval request"
   print "api-query-search-1:          clustering enabled, 5 clusters"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='BBCNews', query='iraq',
                 cluster='true', clustercount=5, fetchtimeout=10000,
                 num=500, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=5,
                                          perpage=10, num=500)
   print "api-query-search-1:  ##################"

   print "api-query-search-1:  ##################"
   print "api-query-search-1:  CASE 4, modified retrieval request"
   print "api-query-search-1:          clustering disabled"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='BBCNews', query='iraq',
                 cluster='false', clustercount=5, fetchtimeout=10000,
                 num=20)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=10, num=20)
   print "api-query-search-1:  ##################"

   print "api-query-search-1:  ##################"
   print "api-query-search-1:  CASE 5, AND query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='BBCNews',
                 query='iraq AND iran',
                 cluster='false', fetchtimeout=10000, num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=10, num=10)
   print "api-query-search-1:  ##################"

   print "api-query-search-1:  ##################"
   print "api-query-search-1:  CASE 6, OR query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='BBCNews',
                 query='iraq OR iran', qsyn='OR',
                 cluster='false', fetchtimeout=10000, num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=10, num=10)
   print "api-query-search-1:  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount ):
      print "api-query-search-1:  Test Passed"
      sys.exit(0)

   print "api-query-search-1:  Test Failed"
   sys.exit(1)
