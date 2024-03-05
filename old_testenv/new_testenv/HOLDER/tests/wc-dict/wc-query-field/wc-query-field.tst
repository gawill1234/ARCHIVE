#!/usr/bin/python


import os, sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   tname = "wc-query-field"
   collection_name = "wc_query_field"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  wc-query-field"
   print tname, ":  Test that wildcard query expansion behaves correctly"
   print tname, ":  in conjunction with field mapping."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name, which="live")   
   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  ##################"
   print tname, ":  CASE 1, query *ming"
   print tname, ":  (match multiple characters at the beginning of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:*ming')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=1, num=1,
                                          tr=1, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 2, query ?ederalist"
   print tname, ":  (match a single character at the beginning of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:?ederalist')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=1, num=1,
                                          tr=1, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 3, query constitut*"
   print tname, ":  (* to match multiple characters at the end of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:constitut*')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                                          perpage=2, num=2,
                                          tr=2, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, query documen?"
   print tname, ":  (? match a single character at the end of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:documen?')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=4, num=4,
                                          tr=4, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 5, query con*n"
   print tname, ":  (* to match mutiple characters in the middle of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:con*n')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=3, num=3,
                                          tr=3, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 6, query su?e"
   print tname, ":  (? to match a single character in the middle of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:su?e')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6,clustercount=0,
                                          perpage=1, num=1,
                                          tr=2, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6,clustercount=0,
                                          perpage=2, num=2,
                                          tr=2, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 7, query c*n*n"
   print tname, ":  (use of multiple * wildcards to match applicable terms)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:c*n*n')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=3, num=3,
                                          tr=3, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 8, query ??clar?????"
   print tname, ":  (use of multiple ? wildcards to match applicable terms )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:??clar?????')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=2, num=2,
                                          tr=2, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 9, query *??cl*"
   print tname, ":  (use of multiple * and ? wildcards to match applicable terms )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:*??cl*')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                          perpage=3, num=3,
                                          tr=3, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 10, query <?x109>"
   print tname, ":  ( query consisting solely of one or more ? wildcards)"
   print tname, ":  ( to match terms of various character lengths )" 
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:????????????????????????????????????????????????????????????????????????????????????????????????????????????')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10, clustercount=0,
                                          perpage=10, num=10,
                                          tr=47, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 11, query <*x109>"
   print tname, ":  ( query consisting solely of one or more * wildcards)"
   print tname, ":  ( to match terms of various character lengths )" 
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:***********************************************************************************************************')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11, clustercount=0,
                                          perpage=10, num=10,
                                          tr=47, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 12, query linux oracle"
   print tname, ":  ( query without any wildcard characters)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:linux title:oracle')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=12, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 13, query oracl*atabase"
   print tname, ":  ( attempt to span words )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:oracl*atabase')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=13, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 14, query \"in???ted list\""

   print tname, ":  ( query matching the ? wildcard in a phrase  )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:"in???ted list"')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=14, clustercount=0,
                                          perpage=1, num=1,
                                          tr=1, testname=tname)
   print tname, ":  ##################"                                    

   print tname, ":  ##################"
   print tname, ":  CASE 15, query \"*tructures, *lgorith*\""
   print tname, ":  ( query matching the * wildcard in a phrase  )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='title:"*tructures, *lgorith*"')
   
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=15, clustercount=0,
                                          perpage=2, num=2,
                                          tr=2, testname=tname)
   print tname, ":  ##################"


   ##############################################################

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
