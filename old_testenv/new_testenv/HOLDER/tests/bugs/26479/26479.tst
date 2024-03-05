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

   collection_name2 = "26479"
   cfile = collection_name2 + '.xml'
   tname = "26479"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  26479 bug test"
   print tname, ":     Create a collection"
   print tname, ":     Do a query which is nested notwithcontaining/and"
   print tname, ":     This test should take no more than 5 minutes"
   q1 = "((prefix FOLLOWEDBY suffix) NOTCONTAINING ADBE)"
   q2 = '((prefix FOLLOWEDBY suffix) NOTCONTAINING ADBE) AND pdf'
   #
   #  q2, above, is the failure equivalent of the query below that is
   #  in the bug.  This was verified on 7.5-8 (a version without the
   #  26479 fix in it, the query times out).
   #((prefix FOLLOWEDBY suffix) NOTCONTAINING ADBE) AND ReviewSetID:6944e4d2 
   #-0970-4961-b679-c1c166d24531
   #

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   print tname, ":  PERFORM CRAWL"
   print tname, ":     Create empty collection", collection_name2

   #
   #   If the collection exists, get rid of it.
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      yy.api_sc_crawler_stop(collection=collection_name2, killit='true')
      yy.api_sc_indexer_stop(collection=collection_name2, killit='true')
      yy.api_sc_delete(xx=xx, collection=collection_name2)

   yy.api_sc_create(collection=collection_name2)
   yy.api_repository_update(xmlfile=cfile)
   yy.api_sc_crawler_start(collection=collection_name2)
   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(source=collection_name2, query=q1, filename="junk")
   try:
      urlcount1 = yy.getTotalResults(resptree=resp)
   except:
      urlcount1 = 0

   print "URLCOUNT1:", urlcount1, "-- Expected: 1"

   try:
      resp = yy.api_qsearch(source=collection_name2, query=q2, filename="junk2")
      try:
         urlcount2 = yy.getTotalResults(resptree=resp)
      except:
         urlcount2 = 0
   except:
      print tname, ":  Query timed out?"
      urlcount2 = 0

   print "URLCOUNT2:", urlcount2, "-- Expected: 1"

   if ( urlcount1 == 1 and urlcount2 == 1 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

