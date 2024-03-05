#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface


if __name__ == "__main__":

   collection_name = "disjunction-1"
   tname = 'disjunction-1'

   colfile = ''.join([collection_name, '.xml'])
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
   print tname, ":  Disjunction queries of the collection."

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":  ALL SSN query, sets with fixed counts"
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='hamilton OR madision',
                       filename='hm1', qsyn='Default')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=6, num=6, filename='hm1',
                      testname=tname)

   print tname, ":  #######################################"

   xx.kill_all_services()

   print tname, ":  so far incomplete.  Test will NOT pass."

   if ( cs_pass == 14 ):
      print tname, ":  Test Passed"
      #xx.stop_crawl(collection=collection_name, force=1)
      #xx.stop_indexing(collection=collection_name, force=1)
      #xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
