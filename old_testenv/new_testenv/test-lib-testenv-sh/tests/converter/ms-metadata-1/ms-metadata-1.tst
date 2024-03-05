#!/usr/bin/python

import sys, time, cgi_interface, vapi_interface
import test_helpers, os

if __name__ == "__main__":

   collection_name = "ms-metadata-1"
   tname = 'ms-metadata-1'

   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])
   maxcount = 10
   i = 0
   cs_pass = 0

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

   print tname, ":  #######################################"
   print tname, ":  Check that office metadata is converted"
   print tname, ":  and put in the index"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":  Look for the publisher, Windows Sucks"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='Windows Sucks',
                       filename='wsuck', qsyn='Default', odup='true')

   #cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
   #                   clustercount=0, perpage=2, num=2, filename='wsuck',
   #                   testname=tname)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=1, num=1, filename='wsuck',
                      testname=tname)

   filename = yy.look_for_file(filename='wsuck')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":  Look for the author/creator, Gary Williams"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='\"Gary Williams\"',
                       filename='auth', qsyn='Default', odup='true')
   #cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
   #                   clustercount=0, perpage=2, num=2, filename='auth',
   #                   testname=tname)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=1, num=1, filename='auth',
                      testname=tname)

   filename = yy.look_for_file(filename='auth')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":  Look for the subject, Peanuts"

   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='Peanuts',
                       filename='subj', qsyn='Default', odup='true')
   #cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
   #                   clustercount=0, perpage=2, num=2, filename='subj',
   #                   testname=tname)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=1, num=1, filename='subj',
                      testname=tname)

   filename = yy.look_for_file(filename='subj')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":  Look for the keywords, filthyelephant"
   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc']
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='filthyelephant',
                       filename='keyw1', qsyn='Default', odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=1, num=1, filename='keyw1',
                      testname=tname)

   filename = yy.look_for_file(filename='keyw1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 5"
   print tname, ":  Look for the keywords, fuzzyllama"
   print tname, ":     CASE DEFERRED DUE TO INCOMPLETE FEATURE"

   #explist = ['smb://testbed5.test.vivisimo.com/testfiles/test_data/metadata_test/exceltest.xls']

   #yy.api_qsearch(xx=xx, source=collection_name,
   #                    query='fuzzyllama',
   #                    filename='keyw2', qsyn='Default', odup='true')

   #cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
   #                   clustercount=0, perpage=1, num=1, filename='keyw2',
   #                   testname=tname)

   #filename = yy.look_for_file(filename='keyw2')
   #urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   #ret = yy.check_list(explist, urllist)
   #if ( ret == 0 ):
   #   print tname, ":     Expected URLs match"
   #   cs_pass = cs_pass + 1
   #else:
   #   print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 6"
   print tname, ":  Look for the keywords, fuzzyfuzzy"

   explist = ['smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/wordtest.doc',
              'smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/xlsxtest.xlsx',
              'smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/pptxtest.pptx',
              'smb://' + os.getenv( 'VIV_SAMBA_LINUX_SERVER' ) + '/' + os.getenv( 'VIV_SAMBA_LINUX_SHARE' ) + '/test_data/metadata_test/docxtest.docx']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='fuzzyfuzzy',
                       filename='keyw3', qsyn='Default', odup='true')
   #cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
   #                   clustercount=0, perpage=6, num=6, filename='keyw3',
   #                   testname=tname)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                      clustercount=0, perpage=4, num=4, filename='keyw3',
                      testname=tname)

   filename = yy.look_for_file(filename='keyw3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   #if ( cs_pass == 12 ):
   if ( cs_pass == 10 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)