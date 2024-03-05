#!/usr/bin/python

import sys, time, cgi_interface, vapi_interface
import getopt
import test_helpers, os

if __name__ == "__main__":

   collection_name = "query_stopword_rm-1"
   tname = 'query_stopword_rm-1'

   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])
   maxcount = 10
   i = 0
   cs_pass = 0
   apicheck = 0

   #
   #   Option to wait or not wait for initial crawl to finish
   #   before beginning refresh cycle.  Default is to wait.
   #
   opts, args = getopt.getopt(sys.argv[1:], "an", ["api", "noapi"])

   for o, a in opts:
      if o in ("-a", "--api"):
         apicheck = 1
      if o in ("-n", "--noapi"):
         apicheck = 0


   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Regular expression queries"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   cex = xx.collection_exists(collection=collection_name)

   if ( cex == 1 ):
      print tname, ":  Old collection exists.  Deleting."
      yy.api_sc_crawler_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_indexer_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_delete(xx=xx, collection=collection_name)
      cex = xx.collection_exists(collection=collection_name)
      if ( cex == 1 ):
         print tname, ":  Old collection still exists.  Trying to continue."

   if ( cex != 1 ):
      print tname, ":  Create and check the base collection"
      xx.create_collection(collection=collection_name, usedefcon=0)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   try:
      yy.api_repository_del(xx=xx, elemtype="options", elemname="query-meta")
   except:
      print tname, ":  Repository delete failed, retrying ..."
      try:
         yy.api_repository_del(xx=xx, elemtype="options", elemname="query-meta")
      except:
         print tname, ":  Repository delete failed, continuing ..."

   print tname, ":  #######################################"
   print tname, ":  Check that office metadata is converted"
   print tname, ":  and put in the index"

   if ( apicheck == 1 ):
      print tname, ":  #######################################"
      print tname, ":  CASE 1"
      print tname, ":  linus was sense, using query-search"
      explist = []
      yy.api_qsearch(xx=xx, source=collection_name,
                          query='linus was sense',
                          filename='norm1', qsyn='Default', odup='true')
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                         clustercount=0, perpage=0, num=0, filename='norm1',
                         testname=tname)

      filename = yy.look_for_file(filename='norm1')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

      ret = yy.check_list(explist, urllist)
      if ( ret == 0 ):
         print tname, ":     Expected URLs match"
         cs_pass = cs_pass + 1
      else:
         print tname, ":     Expected URLs do not match"
   else:
      print tname, ":  #######################################"
      print tname, ":  CASE 1"
      print tname, ":  query-search usage option not selected"
      print tname, ":  Case passes"
      cs_pass = cs_pass + 2

   if ( apicheck == 1 ):
      print tname, ":  #######################################"
      print tname, ":  CASE 2"
      print tname, ":  was test document Peanuts, using query-search"
      explist = []
      yy.api_qsearch(xx=xx, source=collection_name,
                          query='was test document Peanuts',
                          filename='norm2', qsyn='Default', odup='true')
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                         clustercount=0, perpage=0, num=0, filename='norm2',
                         testname=tname)

      filename = yy.look_for_file(filename='norm2')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

      ret = yy.check_list(explist, urllist)
      if ( ret == 0 ):
         print tname, ":     Expected URLs match"
         cs_pass = cs_pass + 1
      else:
         print tname, ":     Expected URLs do not match"
   else:
      print tname, ":  #######################################"
      print tname, ":  CASE 2"
      print tname, ":  query-search usage option not selected"
      print tname, ":  Case passes"
      cs_pass = cs_pass + 2

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":  linus was sense, using query-meta"
   explist = []
   xx.run_query(source=collection_name, query="linus was sense",
                defoutput='querywork/norm3')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=0, num=0, filename='norm3',
                      testname=tname)

   filename = yy.look_for_file(filename='norm3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":  was test document Peanuts, using query-meta"
   explist = []
   xx.run_query(source=collection_name, query="was test document Peanuts",
                defoutput='querywork/norm4')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=0, num=0, filename='norm4',
                      testname=tname)

   filename = yy.look_for_file(filename='norm4')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"
   print tname, ":  #######################################"
   print tname, ":  DO THE REPOSITORY UPDATE"
   print tname, ":  SET STOPWORD REMOVAL TO TRUE"
   yy.api_repository_update(xx=xx, xmlfile="sw_option")
   print tname, ":  #######################################"

   if ( apicheck == 1 ):
      print tname, ":  #######################################"
      print tname, ":  CASE 5"
      print tname, ":  linus was sense query-search"
      explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
      yy.api_qsearch(xx=xx, source=collection_name,
                          query='linus was sense',
                          filename='rm1', qsyn='Default', odup='true')
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                         clustercount=0, perpage=1, num=1, filename='rm1',
                         testname=tname)

      filename = yy.look_for_file(filename='rm1')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

      ret = yy.check_list(explist, urllist)
      if ( ret == 0 ):
         print tname, ":     Expected URLs match"
         cs_pass = cs_pass + 1
      else:
         print tname, ":     Expected URLs do not match"
   else:
      print tname, ":  #######################################"
      print tname, ":  CASE 5"
      print tname, ":  query-search usage option not selected"
      print tname, ":  Case passes"
      cs_pass = cs_pass + 2

   print tname, ":  #######################################"
   print tname, ":  CASE 6"
   print tname, ":  linus was sense query-meta"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
   xx.run_query(source=collection_name, query="linus was sense",
                defoutput='querywork/rm2')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                      clustercount=0, perpage=1, num=1, filename='rm2',
                      testname=tname)

   filename = yy.look_for_file(filename='rm2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   if ( apicheck == 1 ):
      print tname, ":  #######################################"
      print tname, ":  CASE 7"
      print tname, ":  was test document Peanuts using query-search"
      explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
      yy.api_qsearch(xx=xx, source=collection_name,
                          query='was test document Peanuts',
                          filename='rm3', qsyn='Default', odup='true')
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7,
                         clustercount=0, perpage=1, num=1, filename='rm3',
                         testname=tname)

      filename = yy.look_for_file(filename='rm3')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

      ret = yy.check_list(explist, urllist)
      if ( ret == 0 ):
         print tname, ":     Expected URLs match"
         cs_pass = cs_pass + 1
      else:
         print tname, ":     Expected URLs do not match"
   else:
      print tname, ":  #######################################"
      print tname, ":  CASE 7"
      print tname, ":  query-search usage option not selected"
      print tname, ":  Case passes"
      cs_pass = cs_pass + 2

   print tname, ":  #######################################"
   print tname, ":  CASE 8"
   print tname, ":  was test document Peanuts using query-meta"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
   xx.run_query(source=collection_name, query="was test document Peanuts",
                defoutput='querywork/rm4')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8,
                      clustercount=0, perpage=1, num=1, filename='rm4',
                      testname=tname)

   filename = yy.look_for_file(filename='rm4')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 9"
   print tname, ":  linus was sense, using query-meta"
   explist = []
   xx.run_query(source=collection_name, query="linus +was sense",
                defoutput='querywork/norm5')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9,
                      clustercount=0, perpage=0, num=0, filename='norm5',
                      testname=tname)

   filename = yy.look_for_file(filename='norm5')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 10"
   print tname, ":  was test document Peanuts, using query-meta"
   explist = []
   xx.run_query(source=collection_name, query="+was test document Peanuts",
                defoutput='querywork/norm6')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10,
                      clustercount=0, perpage=0, num=0, filename='norm6',
                      testname=tname)

   filename = yy.look_for_file(filename='norm6')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 11"
   print tname, ":  as was, using query-meta"
   print tname, ":  all stopwords, so none are discared"
   explist = []
   xx.run_query(source=collection_name, query="as was",
                defoutput='querywork/norm7', num=50)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11,
                      clustercount=0, perpage=34, num=34, filename='norm7',
                      testname=tname)

   print tname, ":  #######################################"
   print tname, ":  CASE 12"
   print tname, ":  was test document Peanuts (quoted), using query-meta"
   print tname, ":  quoted string, no words removed"
   explist = []
   xx.run_query(source=collection_name, query="\"was test document Peanuts\"",
                defoutput='querywork/norm8')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=12,
                      clustercount=0, perpage=0, num=0, filename='norm8',
                      testname=tname)

   filename = yy.look_for_file(filename='norm8')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 13"
   print tname, ":  was +is test document Peanuts, using query-meta"
   print tname, ":  One of the stopwords is MUST"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
   xx.run_query(source=collection_name, query="was +is test document Peanuts",
                defoutput='querywork/norm9')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=13,
                      clustercount=0, perpage=1, num=1, filename='norm9',
                      testname=tname)

   filename = yy.look_for_file(filename='norm9')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 14"
   print tname, ":  (was test document) AND (+is Peanuts), using query-meta"
   print tname, ":  One of the stopwords is MUST in an AND"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
   xx.run_query(source=collection_name, query="(was test document) AND (+is Peanuts)",
                defoutput='querywork/norm10')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=14,
                      clustercount=0, perpage=1, num=1, filename='norm10',
                      testname=tname)

   filename = yy.look_for_file(filename='norm10')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"
   print tname, ":  #######################################"

   #
   #   Need to delete this so it does not interfere with other tests.
   #
   yy.api_repository_del(xx=xx, elemtype="options", elemname="query-meta")

   if ( cs_pass == 27 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
