#!/usr/bin/python

#
#   Test of the api
#   Test is for changes introduced by index-atomic.
#   This test makes sure that the originator and enqueue-id
#   attributes do not break the original schema model.
#
#   This test checks crawl-delete and crawl-url with and without
#   the new index-atomic attributes both as standalone nodes
#   and as one or more of X in a index-atomic node.
#
#   This tests crawl-url and crawl-delete within the scope of an
#   index-atomic node.   Multiple index-atomics used as
#   crawl-urls node.
#
import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import random
import build_schema_node
from lxml import etree

def do_collection(xx, yy, collection_name2, tname):

   cfile = collection_name2 + '.xml'

   print tname, ":     Create empty collection", collection_name2
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name2)

   yy.api_sc_create(collection=collection_name2, based_on='default-push')
   yy.api_repository_update(xmlfile=cfile)

   yy.api_sc_crawler_start(collection=collection_name2)

   xx.wait_for_idle(collection=collection_name2)

   return

def doquery(xx, collection_name2, myquery):

   resp = yy.api_qsearch(xx=xx, source=collection_name2,
                         query=myquery)

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   return indexedcount


if __name__ == "__main__":

   global tname, yy, collection_name2, xx

   fail = 0

   collection_name = "bug_24497"
   tname = "bug_24497"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  binning-7"
   print tname, ":     query with url encoding at end of query"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"

   do_collection(xx, yy, collection_name, tname)

   print tname, ":  DO SEARCHES"

   idxcnt = doquery(xx, collection_name, "(expiration AND consequence) WITHIN (100000 WORDS)")
   print tname, ":  CASE 1, Actual  , ", idxcnt
   print tname, ":          Expected,  12"
   if ( idxcnt != 12 ):
      fail += 1

   idxcnt = doquery(xx, collection_name, "(perfect AND union) WITHIN (2 WORDS)")
   print tname, ":  CASE 2, Actual  , ", idxcnt
   print tname, ":          Expected,  11"
   if ( idxcnt != 11 ):
      fail += 1

   idxcnt = doquery(xx, collection_name, "(fourth AND sixth) WITHIN (100 WORDS)")
   print tname, ":  CASE 3, Actual  , ", idxcnt
   print tname, ":          Expected,  22"
   if ( idxcnt != 22 ):
      fail += 1

   idxcnt = doquery(xx, collection_name, "(Legislature AND thereof) WITHIN (100000 WORDS)")
   print tname, ":  CASE 4, Actual  , ", idxcnt
   print tname, ":          Expected,  13"
   if ( idxcnt != 13 ):
      fail += 1

   idxcnt = doquery(xx, collection_name,
           "((perfect AND union) WITHIN (2 WORDS)) AND legislature AND thereof")
   print tname, ":  CASE 5, Actual  , ", idxcnt
   print tname, ":          Expected,  5"
   if ( idxcnt != 5 ):
      fail += 1

   #xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)