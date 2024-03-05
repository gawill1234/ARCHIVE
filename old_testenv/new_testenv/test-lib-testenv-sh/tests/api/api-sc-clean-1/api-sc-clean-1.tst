#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, shutil, os, cgi_interface, vapi_interface

if __name__ == "__main__":

   collection_name = "asccln-1"
   colfile = ''.join([collection_name, '.xml'])
   runfile = ''.join([collection_name, '.xml.run'])
   oldfile = ''.join([collection_name, '.xml.old'])

   e_old_size = 7190
   e_run_size = 775

   a_old_size = 0
   a_run_size = 0
   

   ##############################################################
   print "api-sc-clean-1:  ##################"
   print "api-sc-clean-1:  INITIALIZE"
   print "api-sc-clean-1:  search-collection-clean"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   #
   #   Create the collection and run the crawl
   #
   xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name, which='live')
   xx.wait_for_idle(collection=collection_name)

   #
   #   Get the collection data, clean out the data,
   #   and get the collection data again.  Need to 
   #   allow so time for stuff to be updated.
   #
   xx.get_collection(collection=collection_name)
   shutil.move(runfile, oldfile)
   #xx.stop_indexing(collection=collection_name, force=1)
   yy.api_sc_crawler_stop(collection=collection_name, killit='true', subc='live')
   yy.api_sc_indexer_stop(collection=collection_name, killit='true', subc='live')
   yy.api_sc_clean(xx=xx, collection=collection_name, subc='live')
   time.sleep(10)
   xx.get_collection(collection=collection_name)

   #
   #   Clean up the collection we used
   #
   errcnt = xx.get_collection_system_errors(collection=collection_name,
                                            starttime=thebeginning)

   #
   #   Clean up the collection we used
   #
   yy.api_sc_delete(xx=xx, collection=collection_name)

   #
   #   Since the data is nothing of the collection, just
   #   a bunch of stats related to the collection crawl,
   #   I just keyed off of the file size of the collection file
   #   both before and after the clean was done.  Before the clean,
   #   the file should have all of the stats in it.  After,
   #   there should be no stats.  So, the stats file should be
   #   bigger and reasonably consistent in size.  Makes the test
   #   viable without actually reading the contents of the file.
   #   If this is shown to fail too often, or not enough, it will
   #   be changed to a data read and compare of the two files.
   #
   a_old_size = os.stat(oldfile).st_size
   a_run_size = os.stat(runfile).st_size

   if ( a_run_size < a_old_size ):
      print "api-sc-clean-1:  Test Passed"
      sys.exit(0)

   print "api-sc-clean-1:  Test Failed"
   sys.exit(1)
