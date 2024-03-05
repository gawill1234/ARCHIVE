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

   collection_name2 = "22577"
   cfile = collection_name2 + '.xml'
   tname = "22577"

   enqueue_url = "http://testbed4.test.vivisimo.com/"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  22577 bug test"
   print tname, ":     Create a collection"
   print tname, ":     Set live-crawl-dir to something"
   print tname, ":     Crawl one url"
   print tname, ":     Delete the collection"

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

   #
   #   Empty collection to be filled using crawl-urls
   #
   yy.api_sc_create(collection=collection_name2)
   yy.api_repository_update(xmlfile=cfile)

   thebeginning = time.time()

   #
   #   Enqueue and crawl one url.
   #
   print tname, ":     Enqueue url,", enqueue_url
   yy.api_sc_enqueue_url(xx=xx, collection=collection_name2,
                         url=enqueue_url, fallow='true', enq_type='forced')
   xx.wait_for_idle(collection=collection_name2)

   #
   #   Stop the collection services
   #
   yy.api_sc_crawler_stop(collection=collection_name2, killit='true')
   yy.api_sc_indexer_stop(collection=collection_name2, killit='true')

   #
   #   Delete the collection.  This should work.
   #
   try:
      yy.api_sc_delete(xx=xx, collection=collection_name2)
   except:
      print tname, ":  Test Failed"
      sys.exit(1)

   #
   #   Update the collection.  This should fail if the collection
   #   was properly deleted in the above step.
   #
   try:
      yy.api_repository_update(xmlfile=cfile)
   except:
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

