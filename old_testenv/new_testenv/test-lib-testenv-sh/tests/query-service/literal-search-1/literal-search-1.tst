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

   tname = "literal-search-1"
   collection_name = "enron_crawl"
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])

   ######################################i########################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  literal-search (test 1)"
   print tname, ":  Make sure non-alphanumerics like @, ~, -, and ."
   print tname, ":  are searchable."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  CASE 1, query @enron (at sign)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='@enron')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=10, num=10,
                                          tr=34703, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 2, query skilling@enron.com (at, dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='@enron',
                  cluster='true', clustercount=10, num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=10,
                                          perpage=500, num=500,
                                          tr=34703, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 3, query enron.com (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='enron.com',
                  cluster='true', clustercount=5, num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=5,
                                          perpage=500, num=500,
                                          tr=34341, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, query @"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='@',
                  cluster='false', clustercount=5, num=20)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=20, num=20,
                                          tr=35428, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 5,  query .com (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='.com',
                  cluster='false', num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=50, num=50,
                                          tr=35428, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 6, query .skilling (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='.skilling',
                  cluster='false', num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=10, num=10,
                                          tr=6585, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 7, query kenneth.lay (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='kenneth.lay',
                  cluster='false', num=50, qsyn='OR')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=50, num=50,
                                          tr=7372, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 8, Message-ID query of - (dash)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Message-ID',
                  cluster='false', num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=50, num=50,
                                          tr=35420, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 9, query ~ (twiddle)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='~',
                  cluster='false', num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                          perpage=50, num=50,
                                          tr=35428, testname=tname)
   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
