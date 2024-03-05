#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface 
import test_helpers, os

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   collection_name = "aqs-3"
   tname="api-query-search-3"
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])

   ##############################################################
   print "api-query-search-3:  ##################"
   print "api-query-search-3:  INITIALIZE"
   print "api-query-search-3:  query-search (test 3)"
   print "api-query-search-3:     num-per-source overrides num"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print "api-query-search-3:  ##################"
   print "api-query-search-3:  TEST CASES BEGIN"


   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 1, DEFAULTS"
   casecount = casecount + 1
   #test_function(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
   #              cluster='false', fetchtimeout=10000, num=10, nps=2)
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
                 cluster='false', fetchtimeout=10000, num=10, num_per_src=2)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=2, num=2)
   print "api-query-search-3:  ##################"


   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 2, modified retrieval count"
   print "api-query-search-3:          clustering enabled, default"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
                 cluster='true', clustercount=10, fetchtimeout=10000,
                 num=500, num_per_src=2)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=2,
                                          perpage=2, num=2)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 3, modified retrieval request"
   print "api-query-search-3:          clustering enabled, 5 clusters"
   casecount = casecount + 1
   #test_function(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
   #              cluster='true', clustercount=5, fetchtimeout=10000,
   #              num=500, nps=6)
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
                 cluster='true', clustercount=5, fetchtimeout=10000,
                 num=500, num_per_src=6)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=3,
                                             perpage=3, num=3)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=4,
                                             perpage=4, num=4)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 4, modified retrieval request"
   print "api-query-search-3:          clustering disabled"
   casecount = casecount + 1
   #test_function(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
   #              cluster='false', clustercount=5, fetchtimeout=10000,
   #              num=20, nps=45)
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3', query='Hamilton',
                 cluster='false', clustercount=5, fetchtimeout=10000,
                 num=20, num_per_src=45)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                             perpage=3, num=3)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                             perpage=4, num=4)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 5, AND query"
   casecount = casecount + 1
   #test_function(xx=xx, vfunc='query-search', source='aqs-3',
   #              query='',
   #              cluster='false', fetchtimeout=10000, num=50, nps=5)
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3',
                 query='',
                 cluster='false', fetchtimeout=10000, num=50, num_per_src=5)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=5, num=5)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 6, OR query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3',
                 query='Hamilton OR Madison', qsyn='OR',
                 cluster='false', fetchtimeout=10000, num=10)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                             perpage=5, num=5)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                             perpage=6, num=6)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 7, AND query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3',
                 query='We AND the AND people', qsyn='AND',
                 cluster='false', fetchtimeout=10000, num=50)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                             perpage=16, num=16)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                             perpage=18, num=18)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 8, OR query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3',
                 query='We OR the OR people', qsyn='OR',
                 cluster='false', fetchtimeout=10000, num=50, num_per_src=17)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=17, num=17)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 9, AND query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3',
                 query='',
                 cluster='false', fetchtimeout=10000, num=50, num_per_src=46)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                             perpage=43, num=43)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                             perpage=46, num=46)
   print "api-query-search-3:  ##################"

   print "api-query-search-3:  ##################"
   print "api-query-search-3:  CASE 10, AND query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-3',
                 query='',
                 cluster='false', fetchtimeout=10000, num=47, num_per_src=23)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10, clustercount=0,
                                          perpage=23, num=23)
   print "api-query-search-3:  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      print "api-query-search-3:  Test Passed"
      sys.exit(0)

   print "api-query-search-3:  Test Failed"
   sys.exit(1)
