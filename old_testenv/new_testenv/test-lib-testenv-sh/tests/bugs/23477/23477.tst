#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import random
import build_schema_node
from lxml import etree

fixed1 = \
'<crawl-url url="test" status="complete">\
  <crawl-data content-type="application/vxml" encoding="xml">'
varied = '<document vse-key="private-doc-in-example-metadata" default-content-acl="v.' + os.getenv('VIVUSER', 'test-all') +'">'
fixed2 = \
'      <content name="title">About collection example-metadata</content>\
    </document>\
  </crawl-data>\
  <curl-options>\
    <curl-option name="default-allow">allow</curl-option>\
    <curl-option name="max-hops">0</curl-option>\
  </curl-options>\
</crawl-url>'

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
   
   collection_name = "23477"
   tname = "23477"
   
   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":     test for bug 23477"
   
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

   yy.api_sc_create(collection=collection_name, based_on='example-metadata')

   yy.api_sc_crawler_start(collection=collection_name, stype='new')

   xx.wait_for_idle(collection=collection_name)

   myurl = fixed1 + varied + fixed2

   print myurl

   enqueue_it(myurl, collection_name)

   xx.wait_for_idle(collection=collection_name)

   print tname, ":##################################"
   print tname, ":   CASE 1"
   print tname, ":   23477, no annotation, get 1 document"

   explist = ['http://test/']

   resp = yy.api_qsearch(source=collection_name,
                         query='DOCUMENT_KEY:"http://test:80/private-doc-in-example-metadata/"',
                         filename='dkey1')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=1, num=1, filename='dkey1',
                      testname=tname)

   filename = yy.look_for_file(filename='dkey1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":##################################"
   print tname, ":   CASE 2"
   print tname, ":   23477, no annotation, get 1 document with OR"

   explist = ['http://test/']

   resp = yy.api_qsearch(source=collection_name,
                         query='DOCUMENT_KEY:"http://test:80/private-doc-in-example-metadata/" OR whatever',
                         filename='dkey2')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=1, num=1, filename='dkey2',
                      testname=tname)

   filename = yy.look_for_file(filename='dkey2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)

   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   yy.api_repository_update(xmlfile='23477.src')
   rightsuser = 'v.' + os.getenv('VIVUSER', 'test-all')

   xx.wait_for_idle(collection=collection_name)

   print tname, ":##################################"
   print tname, ":   CASE 3"
   print tname, ":   23477, with annotation, get 1 document with blank query"

   explist = ['http://test/']

   resp = yy.api_qsearch(source=collection_name,
                         query='', num=100,
                         filename='dkey6', rights=rightsuser)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=1, num=1, filename='dkey6',
                      testname=tname)

   filename = yy.look_for_file(filename='dkey6')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":##################################"
   print tname, ":   CASE 4"
   print tname, ":   23477, with annotation, get 1 document with category query"

   explist = ['http://test/']

   resp = yy.api_qsearch(source=collection_name,
                         query='DOCUMENT_KEY:"http://test:80/private-doc-in-example-metadata/"',
                         num=100, filename='dkey3', rights=rightsuser)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=1, num=1, filename='dkey3',
                      testname=tname)

   filename = yy.look_for_file(filename='dkey3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":##################################"
   print tname, ":   CASE 5"
   print tname, ":   23477, with annotation, get 1 document with OR query"

   explist = ['http://test/']

   resp = yy.api_qsearch(source=collection_name,
                         query='about OR whatever',
                         num=100, filename='dkey4', rights=rightsuser)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                      clustercount=0, perpage=1, num=1, filename='dkey4',
                      testname=tname)

   filename = yy.look_for_file(filename='dkey4')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":##################################"
   print tname, ":   CASE 6"
   print tname, ":   23477, with annotation, get 1 document with category OR query"

   explist = ['http://test/']

   resp = yy.api_qsearch(source=collection_name,
                         query='DOCUMENT_KEY:"http://test:80/private-doc-in-example-metadata/" OR whatever',
                         num=100, filename='dkey5')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                      clustercount=0, perpage=1, num=1, filename='dkey5',
                      testname=tname)

   filename = yy.look_for_file(filename='dkey5')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)

   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   #############################################################

   if ( cs_pass == 12 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

