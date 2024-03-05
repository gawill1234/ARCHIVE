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
   fail = 0

   tname = "api-query-search-5"
   collection_name = "aqs-5"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  query-search (test 5)"
   print tname, ":  Miscellaneous query-search options"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  CASE 1, query Linux"
   print tname, ":     output-summary option is false"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', osumtf='false')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippets"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, query Linux"
   print tname, ":     output-summary option is true"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', osumtf='true')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippets"
   print tname, ":        Expected,", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 3, query Linux"
   print tname, ":     output-summary option is default (true)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippets"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 4, query Linux"
   print tname, ":     output-content-mode/list options"
   print tname, ":     one item in the list (size)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  ocmode='list', oclist='size')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='size'))
   print tname, ":     Number of size elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='filetype'))
   print tname, ":     Number of filetype elements"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippet elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5, query Linux"
   print tname, ":     output-content-mode/list options"
   print tname, ":     two items in the list (size, filetype)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  ocmode='list', oclist='size filetype')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='size'))
   print tname, ":     Number of size elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='filetype'))
   print tname, ":     Number of filetype elements"
   print tname, ":        Expected, 6"
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippet elements"
   print tname, ":        Expected, 6"
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 6, query Linux"
   print tname, ":     output-content-mode/list options"
   print tname, ":     one item in the list (snippet)"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  ocmode='list', oclist='snippet')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 10
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 12
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='size'))
   print tname, ":     Number of size elements"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='filetype'))
   print tname, ":     Number of filetype elements"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippet elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 7, query Linux"
   print tname, ":     output-content-mode/list options"
   print tname, ":     one item in the list (snippet)"
   print tname, ":     however, the output-summary is set to false"
   casecount = casecount + 1
   yy.api_qsearch(xx=xx, source=collection_name, query='Linux', 
                  ocmode='list', oclist='snippet', osumtf='false')

   if ( yy.TENV.targetos == "solaris" ):
      expsnippet = 5 
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=5, num=5,
                                          tr=6, testname=tname)
   else:
      expsnippet = 6 
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=6, num=6,
                                          tr=6, testname=tname)

   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='size'))
   print tname, ":     Number of size elements"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='filetype'))
   print tname, ":     Number of filetype elements"
   print tname, ":        Expected, 0"
   print tname, ":        Actual,  ", cnt
   if ( cnt != 0 ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   cnt = int(yy.get_item_count(xx=xx, vfunc='query-search', item='snippet'))
   print tname, ":     Number of snippet elements"
   print tname, ":        Expected, ", expsnippet
   print tname, ":        Actual,  ", cnt
   if ( cnt != expsnippet ):
      fail = fail + 1
      print tname, ":        ABOVE ITEM FAILED <<<<<<<<<<<<<<<<"
   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount and fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
