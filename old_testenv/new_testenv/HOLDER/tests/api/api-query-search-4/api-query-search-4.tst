#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface 

def get_ranked_query(xx=None, filename=None, trib=None):

   cmd = "xsltproc"

   if ( trib == None ):
      return

   if ( filename == None ):
      return

   arg1 = ''.join([xx.TENV.testroot, '/utils/xsl/velocity_api.xsl'])
   opts = ''.join(['--stringparam mynode query-url-by-rank --stringparam mytrib ', '%s' % trib])
   dumpit = ''.join(['querywork/', filename, '.wazzat'])

   cmdopts = ' '.join([opts, arg1, dumpit])

   y = xx.exec_command_stdout(cmd, cmdopts, None)

   return y

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10

   collection_name = "aqs-4"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print "api-query-search-4:  ##################"
   print "api-query-search-4:  INITIALIZE"
   print "api-query-search-4:  query-search (test 4)"
   print "api-query-search-4:     start value begins in correct place"
   print "api-query-search-4:     MAJOR missing case (comment):"
   print "api-query-search-4:        start in conjunction with num-per-source"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print "api-query-search-4:  ##################"
   print "api-query-search-4:  TEST CASES BEGIN"


   print "api-query-search-4:  ##################"
   print "api-query-search-4:  CASE 1, DEFAULTS, start = third url"
   casecount = casecount + 3
   spt = 2
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4', query='Hamilton',
                 cluster='false', fetchtimeout=10000, num=10, filename='Ham1')

   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4', query='Hamilton',
                 cluster='false', fetchtimeout=10000, num=10, filename='Ham2',
                 start=spt)

   aaa = get_ranked_query(xx=xx, filename='Ham1', trib=spt)
   bbb = get_ranked_query(xx=xx, filename='Ham2', trib=0)

   if ( aaa == bbb ):
      cs_pass = cs_pass + 1
      print "api-query-search-4:  start uri comparison passed"
   else:
      print "api-query-search-4:  start uri comparison failed"
      print aaa
      print bbb

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1,clustercount=0,
                                             perpage=3, num=3, filename='Ham1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1,clustercount=0,
                                             perpage=1, num=1, filename='Ham2')
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1,clustercount=0,
                                             perpage=4, num=4, filename='Ham1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1,clustercount=0,
                                             perpage=2, num=2, filename='Ham2')
   print "api-query-search-4:  ##################"

   print "api-query-search-4:  ##################"
   print "api-query-search-4:  CASE 2, blank query, start = some mid url"
   casecount = casecount + 3
   spt = 23
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='blank1',
                 cluster='false', fetchtimeout=10000, num=46)

   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='blank2',
                 cluster='false', fetchtimeout=10000, num=46, start=spt)

   aaa = get_ranked_query(xx=xx, filename='blank1', trib=spt)
   bbb = get_ranked_query(xx=xx, filename='blank2', trib=0)

   if ( aaa == bbb ):
      cs_pass = cs_pass + 1
      print "api-query-search-4:  start uri comparison passed"
   else:
      print "api-query-search-4:  start uri comparison failed"
      print aaa
      print bbb

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                                          perpage=43, num=43, filename='blank1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                                          perpage=20, num=20, filename='blank2')
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                                          perpage=46, num=46, filename='blank1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                                          perpage=23, num=23, filename='blank2')
   print "api-query-search-4:  ##################"

   print "api-query-search-4:  ##################"
   print "api-query-search-4:  CASE 3, blank query, start = first url"
   casecount = casecount + 3
   spt = 0
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='blank1',
                 cluster='false', fetchtimeout=10000, num=46)

   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='blank2',
                 cluster='false', fetchtimeout=10000, num=46, start=spt)

   aaa = get_ranked_query(xx=xx, filename='blank1', trib=spt)
   bbb = get_ranked_query(xx=xx, filename='blank2', trib=0)

   if ( aaa == bbb ):
      cs_pass = cs_pass + 1
      print "api-query-search-4:  start uri comparison passed"
   else:
      print "api-query-search-4:  start uri comparison failed"
      print aaa
      print bbb

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                                          perpage=43, num=43, filename='blank1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                                          perpage=43, num=43, filename='blank2')
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                                          perpage=46, num=46, filename='blank1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                                          perpage=46, num=46, filename='blank2')
   print "api-query-search-4:  ##################"

   print "api-query-search-4:  ##################"
   print "api-query-search-4:  CASE 4, blank query, start = last url"
   casecount = casecount + 3
   spt = 45
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='blank1',
                 cluster='false', fetchtimeout=10000, num=46)

   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='blank2',
                 cluster='false', fetchtimeout=10000, num=46, start=spt)

   aaa = get_ranked_query(xx=xx, filename='blank1', trib=spt)
   bbb = get_ranked_query(xx=xx, filename='blank2', trib=0)

   if ( aaa == bbb ):
      cs_pass = cs_pass + 1
      print "api-query-search-4:  start uri comparison passed"
   else:
      print "api-query-search-4:  start uri comparison failed"
      print aaa
      print bbb

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=43, num=43, filename='blank1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=0, num=0, filename='blank2')
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=46, num=46, filename='blank1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=4, clustercount=0,
                                          perpage=1, num=1, filename='blank2')
   print "api-query-search-4:  ##################"

   print "api-query-search-4:  ##################"
   print "api-query-search-4:  CASE 5, blank query, start = negative number"
   casecount = casecount + 3
   spt = -1
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='neg1',
                 cluster='false', fetchtimeout=10000, num=46)

   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='neg2',
                 cluster='false', fetchtimeout=10000, num=46, start=spt)

   aaa = get_ranked_query(xx=xx, filename='neg1', trib=0)
   bbb = get_ranked_query(xx=xx, filename='neg2', trib=0)

   if ( aaa == bbb ):
      cs_pass = cs_pass + 1
      print "api-query-search-4:  start uri comparison passed"
   else:
      print "api-query-search-4:  start uri comparison failed"
      print aaa
      print bbb

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=5, clustercount=0,
                                          perpage=43, num=43, filename='neg1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=5, clustercount=0,
                                          perpage=43, num=43, filename='neg2')
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=5, clustercount=0,
                                          perpage=46, num=46, filename='neg1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=5, clustercount=0,
                                          perpage=46, num=46, filename='neg2')
   print "api-query-search-4:  ##################"

   print "api-query-search-4:  ##################"
   print "api-query-search-4:  CASE 6, blank query, start = greater than avail"
   casecount = casecount + 3
   spt = 46
   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='toobig1',
                 cluster='false', fetchtimeout=10000, num=46)

   yy.api_qsearch(xx=xx, vfunc='query-search', source='aqs-4',
                 query='', filename='toobig2',
                 cluster='false', fetchtimeout=10000, num=46, start=spt)

   aaa = get_ranked_query(xx=xx, filename='toobig1', trib=spt)
   bbb = get_ranked_query(xx=xx, filename='toobig2', trib=0)

   if ( aaa == bbb ):
      cs_pass = cs_pass + 1
      print "api-query-search-4:  start uri comparison passed"
   else:
      print "api-query-search-4:  start uri comparison failed"
      print aaa
      print bbb

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6,clustercount=0,
                                        perpage=43, num=43, filename='toobig1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,clustercount=0,
                                          perpage=0,num=0, filename='toobig2')
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=6,clustercount=0,
                                        perpage=46, num=46, filename='toobig1')
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,clustercount=0,
                                          perpage=0,num=0, filename='toobig2')
   print "api-query-search-4:  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount ):
      xx.delete_collection(collection=collection_name)
      print "api-query-search-4:  Test Passed"
      sys.exit(0)

   print "api-query-search-4:  Test Failed"
   sys.exit(1)
