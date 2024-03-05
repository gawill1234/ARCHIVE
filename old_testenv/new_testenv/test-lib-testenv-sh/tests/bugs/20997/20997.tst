#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   Test for bug 20997.  Checks that a string after
#   a character which would have caused the string to
#   become garbled/destroyed does not by querying for that
#   string.
#
#   The data is in /testenv/samba_test_data/20997/test.xls
#

import sys, time, cgi_interface, vapi_interface 
import test_helpers, os

if __name__ == "__main__":

   fail = 1

   collection_name = "20997"
   tname = "20997"
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
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
   print tname, ":  CASE 1, query for a Japanese string"
   yy.api_qsearch(xx=xx, vfunc='query-search', source='20997',
                  query='これはテスト用のExcelファイル。', filename='Ham1')

   fail = fail + yy.query_result_check(xx=xx,casenum=1,clustercount=0,
                                       perpage=1, num=1, filename='Ham1')
   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( fail == 2 ):
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
