#!/usr/bin/python

#
#   Test to verify that indexing errors are reported in
#   response to api requests search-collection-enqueue-xml and 
#   search-collection-url-status-query.
#

import sys, time, cgi_interface, vapi_interface
import velocityAPI, build_schema_node
import urlparse
import os, subprocess
from lxml import etree

def enqueue_it(srvr, collection, crawl_urls):

   try:
      resp = srvr.api_sc_enqueue_xml(
                       collection=collection,
                       subc='live',
                       crawl_nodes=crawl_urls)
      return resp
   except velocityAPI.VelocityAPIexception:
      ex_xml, ex_text = sys.exc_info()[1]
      success = ex_xml.get('name') == 'search-collection-enqueue-invalid'
      if not success:
         print "BARF, unexpected failure"
         print '%s:  %s' % (collection, ex_text)
         print "Enqueue failed"

   return None

def do_enqueues(srvr, collection): 

   crawl_urls = '<crawl-url url="http://vivisimo.com/fake" status="complete" \
enqueue-type="reenqueued" synchronization="indexed-no-sync"> \
  <crawl-data encoding="xml" content-type="application/vxml"> \
   <document><content name="x" fast-index="int">bar</content></document> \
  </crawl-data> \
</crawl-url>'

   filecount = 0

   cus = '<crawl-url-status/>'
   resp = enqueue_it(srvr, collection, crawl_urls)
   klink = yy.api_sc_url_status_query(collection=collection_name,
                                cusnode=cus)
   print "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
   print "+++ response from search-collection-enqueue-xml +++++"
   print etree.tostring(resp)
   print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   print "+++ response from search-collection-url-status-query +++++"
   print etree.tostring(klink)
   print "+++++++++++++++++++++++++++++++++++++++++++++++++"
   #print etree.tostring(crawl_urls)

   return resp, klink


if __name__ == "__main__":

   tname = '21677'

   collection_name = '21677'

   fail = 0

   ##############################################################
   #
   #  Test 
   #
   print "Test name: ", tname
   print "Test requested in bugzilla issue 21677"
   print "Test to verify that indexing errors are reported in response to api requests search-collection-enqueue-xml and search-collection-url-status-query."

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(8.0)

   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)


   yy.api_sc_create(collection=collection_name, based_on='default-push')

   crawlresp, statresp = do_enqueues(yy, collection_name)

   cerror = crawlresp.xpath("//error/@id")
   serror = statresp.xpath("//error/@id")

   if ( len(cerror) < 1 ):
      fail += 1
      print tname, ": Failure: crawler-service-enqueue-response is missing an error from indexer" 

   if ( len(serror) < 1 ):
      fail += 1
      print tname, ": Failure: crawl-url-status-response is missing an error from indexer"

   if ( fail == 0 ):
      print tname, ":  Crawl url error id, ", cerror[0]
      print tname, ":  Url status error id,", serror[0]
      if ( cerror[0] != serror[0] ):
         fail += 1
         print tname, ":  Errors for bad fast-index differ,"
         print tname, ":  they should be the same."
      else:
         print tname, ":  Errors match as expected."

   ####################################################################

   if ( fail == 0 ):
      print tname, ":  Test Passed"
      xx.delete_collection(collection=collection_name)
      sys.exit(fail)
   else:
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      print tname, ":  Test Failed"
      sys.exit(fail)
