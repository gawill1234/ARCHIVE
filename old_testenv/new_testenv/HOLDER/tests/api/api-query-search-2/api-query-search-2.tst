#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   maxcount = 10
   fail = 0
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   zing = ['file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/fedpaper.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/arizona.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/federa00.htm', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/constitution.pdf']
   zing2 = ['file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/fedpaper.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/constitution.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/federa00.htm', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/constitution.pdf']

   zingsolaris = ['file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/fedpaper.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/arizona.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/federa00.htm']
   zingsolaris2 = ['file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/fedpaper.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/constitution.txt', 'file://///testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-1/doc/federa00.htm']

   collection_name = "aqs-2"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print "api-query-search-2:  ##################"
   print "api-query-search-2:  INITIALIZE"
   print "api-query-search-2:  query-search (test 2)"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print "api-query-search-2:  ##################"
   print "api-query-search-2:  TEST CASES BEGIN"


   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 1, DEFAULTS"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2', query='Hamilton',
                 cluster='false', fetchtimeout=10000, num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                       perpage=4, num=4)
   mylist = yy.get_doc_attr_values(xx=xx, item='url',
                                   vfunc='query-search')
   f1 = yy.check_list(zing, mylist)
   f2 = yy.check_list(zing2, mylist)

   print "api-query-search-2:  The above is the output of two list comparisons"
   print "api-query-search-2:  One of them will have succeeded, one failed"
   print "api-query-search-2:  You should see two lines referencing"
   print "api-query-search-2:  constitution.txt and arizona.txt (duplicates)"
   print "api-query-search-2:  There should be one reference for each one"
   if ( f1 != 0 and f2 != 0 ):
      print "api-query-search-2:      ##### LIST COMPARE FAILURE #####"
      print "api-query-search-2:  The above list comparisons both failed"
      print "api-query-search-2:  when one of them should have passed"
      fail = 1
   print "api-query-search-2:  ##################"


   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 2, modified retrieval count"
   print "api-query-search-2:          clustering enabled, default"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2', query='Hamilton',
                 cluster='true', clustercount=10, fetchtimeout=10000,
                 num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=4,
                                          perpage=4, num=4)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 3, modified retrieval request"
   print "api-query-search-2:          clustering enabled, 5 clusters"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2', query='Hamilton',
                 cluster='true', clustercount=5, fetchtimeout=10000,
                 num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=4,
                                          perpage=4, num=4)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 4, modified retrieval request"
   print "api-query-search-2:          clustering disabled"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2', query='Hamilton',
                 cluster='false', clustercount=5, fetchtimeout=10000,
                 num=20)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                             perpage=3, num=3)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                             perpage=4, num=4)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 5, AND query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2',
                 query='Hamilton AND Madison',
                 cluster='false', fetchtimeout=10000, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                             perpage=4, num=4)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 6, OR query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2',
                 query='Hamilton OR Madison', qsyn='OR',
                 cluster='false', fetchtimeout=10000, num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                             perpage=6, num=6)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 7, OR query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2',
                 query='We OR the OR people', qsyn='OR',
                 cluster='false', fetchtimeout=10000, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                             perpage=35, num=35)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 8, AND query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2',
                 query='We AND the AND people', qsyn='AND',
                 cluster='false', fetchtimeout=10000, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                             perpage=18, num=18)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"
   print "api-query-search-2:  CASE 9, + query"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2',
                 query='We+the+people',
                 cluster='false', fetchtimeout=10000, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                             perpage=5, num=5)
   print "api-query-search-2:  ##################"

   print "api-query-search-2:  ##################"

   queryfile = "querywork/myquery"
   xx.run_query(collection='aqs-2', defoutput=queryfile, dupshow="0", query="")
   qcnt = int(xx.count_query_urls(filenm=queryfile))

   print "api-query-search-2:  CASE 10, blank query compared to \'search\'"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-2',
                 query='',
                 cluster='false', fetchtimeout=10000, num=250)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10, clustercount=0,
                                          perpage=qcnt, num=qcnt)
   print "api-query-search-2:  ##################"

   ##############################################################

   #xx.kill_all_services()

   if ( cs_pass == casecount and fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print "api-query-search-2:  Test Passed"
      sys.exit(0)

   print "api-query-search-2:  Test Failed"
   sys.exit(1)
