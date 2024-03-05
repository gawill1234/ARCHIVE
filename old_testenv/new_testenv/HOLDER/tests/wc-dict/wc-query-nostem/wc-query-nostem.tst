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

   tname = "wc-query-nostem"
   collection_name = "wc_query_nostem"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  wc-query-nostem"
   print tname, ":  Test that wildcard query expansion behaves correctly"
   print tname, ":  without stemmers defined on index-only terms."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name, which="live")   
   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   print tname, ":  ##################"
   print tname, ":  CASE 1, query *linux"
   print tname, ":  (match multiple characters at the beginning of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*linux')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 2, query ?egenerate"
   print tname, ":  (match a single character at the beginning of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='?egenerate')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=2, num=2,
                                          tr=2, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 3, query constitut*"
   print tname, ":  (* to match multiple characters at the end of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='constitut*')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                                          perpage=10, num=10,
                                          tr=18, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, query wai?"
   print tname, ":  (? match a single character at the end of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='wai?')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=7, num=7,
                                          tr=8, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=8, num=8,
                                          tr=8, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 5, query su*e"
   print tname, ":  (* to match mutiple characters in the middle of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='su*e')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=10, num=10,
                                          tr=26, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 6, query su?e"
   print tname, ":  (? to match a single character in the middle of a term)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='su?e')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6, clustercount=0,
                                          perpage=9, num=9,
                                          tr=11, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6, clustercount=0,
                                          perpage=10, num=10,
                                          tr=11, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 7, query m*i*on"
   print tname, ":  (use of multiple * wildcards to match applicable terms)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='m*i*on')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=10, num=10,
                                          tr=22, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 8, query ???land"
   print tname, ":  (use of multiple ? wildcards to match applicable terms )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='???land')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=3, num=3,
                                          tr=3, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 9, query *cia??"
   print tname, ":  (use of multiple * and ? wildcards to match applicable terms )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='*cia??')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                          perpage=10, num=10,
                                          tr=15, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 10, query <?x109>"
   print tname, ":  ( query consisting solely of one or more ? wildcards)"
   print tname, ":  ( to match terms of various character lengths )" 
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='????????????????????????????????????????????????????????????????????????????????????????????????????????????')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10, clustercount=0,
                                          perpage=10, num=10,
                                          tr=47, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 11, query <*x109>"
   print tname, ":  ( query consisting solely of one or more * wildcards)"
   print tname, ":  ( to match terms of various character lengths )" 
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='***********************************************************************************************************')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11, clustercount=0,
                                          perpage=10, num=10,
                                          tr=47, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 12, query linux oracle"
   print tname, ":  ( query without any wildcard characters)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='linux oracle')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=12, clustercount=0,
                                          perpage=3, num=3,
                                          tr=3, testname=tname)
   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 13, query oracl*atabase"
   print tname, ":  ( attempt to span words )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='oracl*atabase')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=13, clustercount=0,
                                          perpage=0, num=0,
                                          tr=0, testname=tname)
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 14, query \"o?????? database\""
   print tname, ":  ( query matching the ? wildcard in a phrase  )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='"o????? database"')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=14,clustercount=0,
                                          perpage=3, num=3,
                                          tr=4, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=14,clustercount=0,
                                          perpage=4, num=4,
                                          tr=4, testname=tname)
   print tname, ":  ##################"                                    

   print tname, ":  ##################"
   print tname, ":  CASE 15, query \"o* database\""
   print tname, ":  ( query matching the * wildcard in a phrase  )"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='"o* database"')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=15,clustercount=0,
                                          perpage=4, num=4,
                                          tr=5, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=15,clustercount=0,
                                          perpage=5, num=5,
                                          tr=5, testname=tname)
   print tname, ":  ##################"


   ##############################################################

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
