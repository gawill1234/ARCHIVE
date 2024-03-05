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
   fail = 0

   tname = "api-query-search-7"
   collection_name = "aqs-7"
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  query-search (test 5)"
   print tname, ":  Miscellaneous query-search options"
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
   print tname, ":  CASE 1, query Hamilton"
   print tname, ":     output-duplicates option is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Hamilton',
                  osumtf='false', odup='true')


   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=5, num=5,
                                          tr=5, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, query Hamilton"
   print tname, ":     output-duplicates option is false"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Hamilton',
                  osumtf='false', odup='false')


   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                                          perpage=3, num=3,
                                          tr=5, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                                          perpage=4, num=4,
                                          tr=5, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 3, query Linux"
   print tname, ":     output-shingles option is false"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux',
                  osumtf='false', oshing='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_doc_attr_count(xx=xx, vfunc='query-search', item='mwi-shingle'))
   print tname, ":     Number of mwi-shingles"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 4, query Linux"
   print tname, ":     output-shingles option is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux',
                  osumtf='false', oshing='true')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_doc_attr_count(xx=xx, vfunc='query-search', item='mwi-shingle'))
   print tname, ":     Number of mwi-shingles"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5, query Linux"
   print tname, ":     output-key option is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', okey='true')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=5, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=5, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_doc_attr_count(xx=xx, vfunc='query-search', item='key'))
   print tname, ":     Number of key elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 6, query Linux"
   print tname, ":     output-key option is false"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', okey='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_doc_attr_count(xx=xx, vfunc='query-search', item='key'))
   print tname, ":     Number of key elements"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 7, query Linux"
   print tname, ":     query-object option is set, no query"
   print tname, ":     this should be the same a a query of linux"
   casecount = casecount + 1
   query_obj = "<operator logic=\"and\"><term field=\"query\" str=\"linux\" position=\"0\" processing=\"strict\" input-type=\"user\" /></operator>"
   yy.api_qsearch(xx=xx, source=collection_name, qobj=query_obj, 
                  osumtf='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=7, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=7, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 8, query Linux OR hamilton"
   print tname, ":     query-object option is set, no query"
   print tname, ":     nested operators"
   casecount = casecount + 1
   query_obj = "<operator logic=\"and\"><operator logic=\"or\" middle-string=\"OR\" name=\"OR0\" precedence=\"0\"><term field=\"query\" str=\"linux\" position=\"0\" processing=\"strict\" input-type=\"user\" /><term field=\"query\" str=\"hamilton\" position=\"1\" processing=\"strict\" input-type=\"user\" /></operator></operator>"
   yy.api_qsearch(xx=xx, source=collection_name, qobj=query_obj, 
                  osumtf='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=8, clustercount=0,
                                          perpage=8, num=8,
                                          tr=11, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=8, clustercount=0,
                                          perpage=10, num=10,
                                          tr=11, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 9, query Linux OR hamilton"
   print tname, ":     Results here should mirror case 8 above"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='linux OR hamilton', 
                  osumtf='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=9, clustercount=0,
                                             perpage=8, num=8,
                                             tr=11, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=9, clustercount=0,
                                          perpage=10, num=10,
                                          tr=11, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 10, query Linux OR hamilton"
   print tname, ":     query-object option is set, no query"
   print tname, ":     One operator, nested terms"
   print tname, ":     Results here should mirror case 8 above"
   casecount = casecount + 1
   query_obj = "<operator logic=\"or\"><term field=\"query\" str=\"linux\" position=\"0\" processing=\"strict\" input-type=\"user\" /><term field=\"query\" str=\"hamilton\" position=\"1\" processing=\"strict\" input-type=\"user\" /></operator>"
   yy.api_qsearch(xx=xx, source=collection_name, qobj=query_obj, 
                  osumtf='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=10,clustercount=0,
                                          perpage=8, num=8,
                                          tr=11, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=10,clustercount=0,
                                          perpage=10, num=10,
                                          tr=11, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 11, query Linux OR hamilton"
   print tname, ":     query-condition-object should limit results to"
   print tname, ":     be as if the query was only linux"
   casecount = casecount + 1
   query_obj = "<operator logic=\"and\"><term field=\"query\" str=\"linux\" position=\"0\" processing=\"strict\" input-type=\"user\" /></operator>"
   yy.api_qsearch(xx=xx, source=collection_name, query='linux OR hamilton', 
                  osumtf='false', qcondobj=query_obj)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 12, query Linux OR hamilton using query-object"
   print tname, ":     query-condition-object should limit results to"
   print tname, ":     be as if the query was only linux"
   casecount = casecount + 1
   query_obj1 = "<operator logic=\"or\"><term field=\"query\" str=\"linux\" position=\"0\" processing=\"strict\" input-type=\"user\" /><term field=\"query\" str=\"hamilton\" position=\"1\" processing=\"strict\" input-type=\"user\" /></operator>"
   query_obj2 = "<operator logic=\"and\"><term field=\"query\" str=\"linux\" position=\"0\" processing=\"strict\" input-type=\"user\" /></operator>"
   yy.api_qsearch(xx=xx, source=collection_name, qobj=query_obj1, 
                  osumtf='false', qcondobj=query_obj2)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=12,clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=12,clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   print tname, ":  ##################"


   print tname, ":  ##################"
   print tname, ":  CASE 13, query Hamilton"
   print tname, ":     output-score option is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Hamilton',
                  osumtf='false', oscore='true')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 3
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=13,clustercount=0,
                                          perpage=3, num=3,
                                          tr=5, testname=tname)
   else:
      expsnippet = 4
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=13,clustercount=0,
                                          perpage=4, num=4,
                                          tr=5, testname=tname)

   cnt1 = int(yy.get_doc_attr_count(xx=xx, vfunc='query-search', item='score'))
   print tname, ":     Number of scores"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt1
   if ( cnt1 != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   sclist1 = yy.get_doc_attr_values(xx=xx, vfunc='query-search', item='score')
   print tname, ":     docs scores"
   print tname, ":", sclist1
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 14, query Hamilton"
   print tname, ":     output-score option is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Hamilton',
                  osumtf='false', oscore='false')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 3
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=14,clustercount=0,
                                          perpage=3, num=3,
                                          tr=5, testname=tname)
   else:
      expsnippet = 4
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=14,clustercount=0,
                                          perpage=4, num=4,
                                          tr=5, testname=tname)

   cnt2 = int(yy.get_doc_attr_count(xx=xx, vfunc='query-search', item='score'))
   print tname, ":     Number of scores"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt2
   if ( cnt2 != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   sclist2 = yy.get_doc_attr_values(xx=xx, vfunc='query-search', item='score')
   print tname, ":     docs scores"
   print tname, ":", sclist2

   if ( cnt1 != cnt2 ):
      fail = fail + 1
      print tname, ":        Score count mismatch between 13 and 14"
   else:
      i = 0
      while ( i < cnt1 ):
         if ( sclist1[i] <= sclist2[i] ):
            fail = fail + 1
            print tname, ":        output-score(true), ", sclist1[i]
            print tname, ":        output-score(false),", sclist2[i]
            print tname, ":        Score value question between 13 and 14"
         i = i + 1
  
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 15, query Linux"
   print tname, ":     output-cache-references is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', ocacheref='true')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=15,clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=15,clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_query_data(xx=xx, vfunc='query-search',
             trib='cache-url-count'))
   print tname, ":     Number of key elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 16, query Linux"
   print tname, ":     output-cache-data is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', ocachedata='true')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=16,clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=16,clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_query_data(xx=xx, vfunc='query-search',
             trib='cache-data-count'))
   print tname, ":     Number of key elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 17, query Linux"
   print tname, ":     Supply authorization"
   print tname, ":        USER =", yy.TENV.user
   print tname, ":        PASS =", yy.TENV.pswd
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', user=yy.TENV.user, passwd=yy.TENV.pswd)

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=17,clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=17,clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 18, query Linux"
   print tname, ":     output-sort-keys is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', obc='size')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=18,clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=18,clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   olist = yy.get_content_attr_values_by_name(xx=xx, vfunc='query-search',
                                        item='output-action', name='size')
   #if ( olist != [] ):
   #   for item in olist:
   #      if ( item != 'bold' ):
   #         fail = fail + 1
   #         print tname, ":     bold not found in size when it should be"
   #else:
   #   fail = fail + 1
   #   print tname, ":     bold not found in size when it should be"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 19, query Linux"
   print tname, ":     output-sort-keys is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  osumtf='false', obc='title', obce='true')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=19,clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=19,clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)
   olist = yy.get_content_attr_values_by_name(xx=xx, vfunc='query-search',
                                        item='output-action', name='title')
   #if ( olist != [] ):
   #   for item in olist:
   #      if ( item == 'bold' ):
   #         fail = fail + 1
   #         print tname, ":     bold found in title when it should not be"

   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount and fail == 0 ):
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
