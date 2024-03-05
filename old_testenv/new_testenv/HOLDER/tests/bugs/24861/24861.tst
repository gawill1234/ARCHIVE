#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   Test for bug 24861.  Checks that a string after
#   a character which would have caused the string to
#   become garbled/destroyed does not by querying for that
#   string.
#
#   The data is in /testenv/samba_test_data/24861/169238.1
#

import sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   fail = 1

   collection_name = "24861"
   tname = "24861"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
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
   print tname, ":  CASE 1, query for a word perfect doc"
   yy.api_qsearch(xx=xx, vfunc='query-search', source='24861',
                  query='"certificate of service"', filename='Ham1')

   fail = fail + yy.query_result_check(xx=xx,casenum=1,clustercount=0,
                                       perpage=1, num=1, filename='Ham1')
   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( fail == 2 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
