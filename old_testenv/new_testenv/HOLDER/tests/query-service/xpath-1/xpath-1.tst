#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface, tc_generic


if __name__ == "__main__":

   collection_name = "xpath-1"
   tname = 'xpath-1'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Regular expression queries of non-alphanum characters"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()
   xx.version_check(7.5)

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
      xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  #######################################"
   print tname, ":  Single item queries of each type to make sure"
   print tname, ":     collection exists"

   print tname, ":  Single dvd"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='Mary Poppins',
                       filename='pop')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=0,
                      clustercount=0, perpage=1, num=1, filename='pop',
                      testname=tname)

   if ( cs_pass == 1 ):
      print tname, ":  Collection creation OK"
      print tname, ":  Continuing to actual regex test cases"
   else:
      print tname, ":  Collection creation failed"
      print tname, ":  Test Failed"
      sys.exit(1)
   

   print tname, ":  #######################################"
   print tname, ":  Regex queries of the collection."
   print tname, ":     Regex expressions validated with grep -E (egrep)"

   zz.tc_begin(tname=tname, tc_num=1, tc_comment="Date of 3/15")
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='March 15',
                       filename='ssn1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      perpage=2, num=2, filename='ssn1',
                      clustercount=0, testname=tname)

   zz.tc_end(tname=tname, tc_num=1)
   print tname, ":  #######################################"

   if ( cs_pass == 6 ):
      print tname, ":  Test Passed"
      #xx.stop_crawl(collection=collection_name, force=1)
      #xx.stop_indexing(collection=collection_name, force=1)
      #xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
