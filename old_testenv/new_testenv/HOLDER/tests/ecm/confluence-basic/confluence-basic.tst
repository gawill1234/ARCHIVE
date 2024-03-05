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

   collection_name2 = "my_confluence"
   cfile = collection_name2 + '.xml'
   tname = "confluence-basic"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Confluence basic crawl test"
   print tname, ":     Create a collection"
   print tname, ":     Do a query which is nested notwithcontaining/and"
   print tname, ":     This test should take no more than 5 minutes"

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

   #try:
   #   yy.api_repository_del(elemtype="function", 
   #                         elemname="vse-crawler-seed-livelink")
   #except:
   #   print "function vse-crawler-seed-livelink not in repository"

   #try:
   #   yy.api_repository_del(elemtype="function", 
   #                         elemname="vse-crawler-seed-livelink-users")
   #except:
   #   print "function vse-crawler-seed-livelink-users not in repository"

   #try:
   #   yy.api_repository_del(elemtype="function", 
   #                         elemname="livelink-rights")
   #except:
   #   print "function livelink-rights not in repository"

   #yy.api_repository_add(xmlfile="function.vse-crawler-seed-livelink.xml")
   #yy.api_repository_add(xmlfile="function.livelink-rights.xml")
   #yy.api_repository_add(xmlfile="function.vse-crawler-seed-livelink-users.xml")

   yy.api_sc_create(collection=collection_name2)
   yy.api_repository_update(xmlfile=cfile)
   yy.api_sc_crawler_start(collection=collection_name2)
   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(source=collection_name2, query='',  
                         num=5000, filename="junk")
   try:
      urlcount1 = yy.getTotalResults(resptree=resp)
   except:
      urlcount1 = 0

   print "URLCOUNT1:", urlcount1, "-- Expected: 2734"

   if ( urlcount1 == 2734 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

