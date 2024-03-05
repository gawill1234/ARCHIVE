#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   This test is identical to files-2loop except it uses the old
#   way for creating and starting a collection and it runs in staging.
#
#   Test request from Stan in Bug 25854
#

import sys, time, cgi_interface, vapi_interface 
import shutil, velocityAPI
from lxml import etree
import urllib2

#
#   If this function exits normally, the test passes.
#
def start_the_crawl(tname=None, xx=None, yy=None, collection=None):

   if ( collection is None ):
      print tname, ":  BARF ..."
      print tname, ":  Test Failed, no collection"
      sys.exit(1)

   colfile = ''.join([collection, '.xml'])

   yy.api_sc_create(collection=collection, based_on='default-push')
   yy.api_repository_update(xmlfile=colfile)
   print tname, ":  Starting the first crawl in live"
   yy.api_sc_crawler_start(collection=collection, stype='new')
   print tname, ":  Starting the second crawl in staging"
   try:
      yy.api_sc_crawler_start(collection=collection, 
                              stype='new', subc='staging')
   except urllib2.URLError:
      print tname, ":  start appears to have locked up"
      print tname, ":  Attemting to delete collection to assure"
      print tname, ":  the target system is not locked for subsequent"
      print tname, ":  tests."
      xx.delete_collection(collection=collection, force=1)
      print tname, ":  Test Failed"
      sys.exit(1)

   return

if __name__ == "__main__":

   fail = 1

   collection_name = "files-hang"
   tname = "files-hang"
   colfile = collection_name + '.xml'

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE, Source is Bug 25854"
   print tname, ":     Purpose is to assure that two quick starts of"
   print tname, ":     staging and live in the same collection do not"
   print tname, ":     cause the collection to hang."
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name, force=1)

   start_the_crawl(tname, xx, yy, collection_name)
   xx.delete_collection(collection=collection_name, force=1)

   print tname, ":  Test Passed"
   sys.exit(0)

