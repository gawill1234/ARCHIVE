#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import random
import build_schema_node
from lxml import etree

badurl = '<crawl-url url="http://boguser.com/c" status="complete" synchronization="indexed" forced-vse-key="bar" forced-vse-key-normalized="forced-vse-key-normalized" enqueue-type="reenqueued">\
  <crawl-data>\
  This is right.\
  </crawl-data>\
  <crawl-data content-type="text/xml">\
  This is wrong.\
  </crawl-data>\
  <curl-options>\
    <curl-option name="default-allow">allow</curl-option>\
  </curl-options>\
</crawl-url>'

delurl = '<crawl-delete url="http://boguser.com/c"/>'

def enqueue_it(crawl_urls=None, collection_name=None):

   resp = None

   print "#########################"
   print "ENQUEUE THIS:"
   print crawl_urls
   print "#########################"

   try:
      resp = yy.api_sc_enqueue_xml(
                       collection=collection_name,
                       subc='live',
                       crawl_nodes=crawl_urls)
   except velocityAPI.VelocityAPIexception:
         ex_xml, ex_text = sys.exc_info()[1]
         print "BARF, unexpected failure"
         print '%s:  %s' % (collection, ex_text)
         print "Enqueue failed"


   print "#########################"
   print "RESPONSE WAS THIS:"
   print etree.tostring(resp)
   print "#########################"
   return resp

if __name__ == "__main__":

   fail = 1
   cs_pass = 0
   
   collection_name = "21852"
   tname = "21852"
   
   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  audit logs test 1"
   
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()
   
   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

   yy.api_sc_create(collection=collection_name, based_on='default-push')

   explist = ['http://boguser.com/c']

   enqueue_it(badurl, collection_name)
   xx.wait_for_idle(collection=collection_name)

   resp = yy.api_qsearch(source=collection_name,
                         query='This is right',
                         filename='correct')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=1, num=1, filename='correct',
                      testname=tname)

   filename = yy.look_for_file(filename='correct')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"


   resp = yy.api_qsearch(source=collection_name,
                         query='This is wrong',
                         filename='correct')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=0, num=0, filename='correct',
                      testname=tname)

   filename = yy.look_for_file(filename='correct')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list([], urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   #############################################################

   enqueue_it(delurl, collection_name)
   xx.wait_for_idle(collection=collection_name)

   resp = yy.api_qsearch(source=collection_name,
                         query='This is right',
                         filename='correct')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=0, num=0, filename='correct',
                      testname=tname)

   filename = yy.look_for_file(filename='correct')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list([], urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   resp = yy.api_qsearch(source=collection_name,
                         query='This is wrong',
                         filename='correct')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=0, num=0, filename='correct',
                      testname=tname)

   filename = yy.look_for_file(filename='correct')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list([], urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   if ( cs_pass == 8 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

