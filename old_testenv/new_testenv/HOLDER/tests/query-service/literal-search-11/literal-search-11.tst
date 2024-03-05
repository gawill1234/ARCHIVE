#!/usr/bin/python


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

   tname = "literal-search-11"
   collection_name = "enron_crawl10"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  literal-search (test 11) with wildcard expressions"
   print tname, ":  Make sure non-alphanumerics like @, ~, -, and ."
   print tname, ":  are searchable."
   print tname, ":  We are using a modified index stream(tokenizer)"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   yy.api_repository_update(xx=xx, xmlfile="wc_options")

   cex = xx.collection_exists(collection=collection_name)

   if ( cex != 1 ):
      print tname, ":  Create and check the base collection"
      xx.create_collection(collection=collection_name, usedefcon=1)
      xx.start_crawl(collection=collection_name)
   else:
      xx.start_crawl(collection=collection_name)

   xx.wait_for_idle(collection=collection_name)

   thebeginning = time.time()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  CASE 1, query *@enron (at sign)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*@enron')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=10, num=10,
                                          tr=13393, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 2, query skilling@enron.com (at, dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*skilling@enron.com',
                  cluster='true', clustercount=10, num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=10,
                                          perpage=500, num=500,
                                          tr=3403, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 2a, query skilling@enron.com (at, dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*sk*ling@enron.com',
                  cluster='true', clustercount=10, num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=10,
                                          perpage=500, num=500,
                                          tr=3403, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 3, query enron.com (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*enron.com',
                  cluster='true', clustercount=5, num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=5,
                                          perpage=500, num=500,
                                          tr=34341, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, query @"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*@*',
                  cluster='false', clustercount=5, num=20)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 4a, query @"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*lling@en*',
                  cluster='false', clustercount=5, num=20)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=20, num=20,
                                          tr=3676, testname=tname)
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 4b, query @"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*g@*',
                  cluster='false', clustercount=5, num=20)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=20, num=20,
                                          tr=10359, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 5,  query *com (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*com',
                  cluster='false', clustercount=5, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5a,  query *.com (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*.com',
                  cluster='false', clustercount=5, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5b,  query .com (dot)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='.com',
                  cluster='false', clustercount=5, num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=11, num=11,
                                          tr=20, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 6, query jeff_skilling@enron.com (_ not part of word)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name,
                  query='*ff_skilling@enron.com',
                  cluster='false', num=10)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=10, num=10,
                                          tr=21, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 7, query kenneth.lay (should not be a word)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name,
                  query='*enneth.lay', qsyn='OR',
                  cluster='false', num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 8, kenneth.lay@enron.com (should be a word)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name,
                  query='kenneth.lay@enr*com',
                  cluster='false', num=500)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=500, num=500,
                                          tr=3577, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 9, query ~ (twiddle)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name,
                  query='~*',
                  cluster='false', num=50)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                          perpage=50, num=50,
                                          tr=323, testname=tname)
   print tname, ":  ##################"

   ##############################################################

   xx.repo_delete(elemtype="options", elemname="query-meta")

   xx.kill_all_services()

   if ( cs_pass == casecount ):
      #xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
