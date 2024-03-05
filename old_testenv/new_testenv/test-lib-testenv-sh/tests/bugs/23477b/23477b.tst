#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import random
import build_schema_node
from lxml import etree

def document1():

   me = os.getenv('VIVUSER', 'test-all')

   myurl = build_schema_node.create_crawl_url(url="garbage", status="complete")
   mydata = build_schema_node.create_crawl_data(contenttype="application/vxml", 
                              encoding="xml", addnodeto=myurl)
   doc1 = build_schema_node.create_document(addnodeto=mydata)
   copts = build_schema_node.create_curl_options(addnodeto=myurl)
   build_schema_node.create_curl_option(name="default-allow", text="allow", addnodeto=copts)
   build_schema_node.create_curl_option(name="max-hops", text="0", addnodeto=copts)
   build_schema_node.create_content(acl=me, text='word-i-can-see', addnodeto=doc1)
   build_schema_node.create_content(acl='not-me', text='word-i-cant-see', addnodeto=doc1)
   build_schema_node.create_content(acl=me, text='word-i-can-see', addnodeto=doc1)

   return myurl

def document2():

   me = os.getenv('VIVUSER', 'test-all')

   myurl = build_schema_node.create_crawl_url(url="moregarbage", status="complete")
   mydata = build_schema_node.create_crawl_data(contenttype="application/vxml", 
                              encoding="xml", addnodeto=myurl)

   doc1 = build_schema_node.create_document(addnodeto=mydata, url="moregarbage",
                                            vsekey="doc",
                                            vsekeynormalized="vse-key-normalized")

   copts = build_schema_node.create_curl_options(addnodeto=myurl)
   build_schema_node.create_curl_option(name="default-allow", text="allow", addnodeto=copts)
   build_schema_node.create_curl_option(name="max-hops", text="0", addnodeto=copts)

   build_schema_node.create_content(name="acl-skip-1", text="aclskipword1",
                                    acl=me,  addnodeto=doc1)
   build_schema_node.create_content(name="acl-skip-2", text="notaclskipword",
                                    acl="not-me",  addnodeto=doc1)
   build_schema_node.create_content(name="acl-skip-3", text="aclskipword2 aclskipword3", 
                                    acl=me, addnodeto=doc1)

   return myurl

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

def do_case(casenum=0, query=None, explist=[], acluser=None, count=1):

   global collection_name, tname

   cs_pass = 0

   filename = "dkey" + '%s' % casenum

   print tname, ":##################################"
   print tname, ":   CASE", '%s' % casenum
   print tname, ":     Query = ", query
   print tname, ":     Rights =", acluser

   resp = yy.api_qsearch(source=collection_name,
                         query=query, num=200,
                         filename=filename, rights=acluser)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=casenum,
                      clustercount=0, perpage=count, num=count,
                      filename=filename,
                      testname=tname)

   filename = yy.look_for_file(filename=filename)
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   return cs_pass

if __name__ == "__main__":

   global collection_name, tname

   fail = 1
   cs_pass = 0
   
   collection_name = "23477b"
   tname = "23477b"
   
   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":     test for bug 23447"
   
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

   yy.api_repository_update(xmlfile='23477b.src')

   xx.wait_for_idle(collection=collection_name)

   acluser = os.getenv('VIVUSER', 'test-all')

   myurl = document1()
   enqueue_it(etree.tostring(myurl), collection_name)
   xx.wait_for_idle(collection=collection_name)

   explist = ['http://garbage/']
   qstring = ''
   cs_pass += do_case(casenum=1, query=qstring, 
                      explist=explist, acluser=acluser, count=1)

   explist = ['http://garbage/']
   qstring = 'word-i-can-see WITHIN (({content} THRU {content}) CONTAINING word-i-cant-see)'
   cs_pass += do_case(casenum=2, query=qstring, 
                      explist=explist, acluser=None, count=1)

   #############################################################

   myurl = document2()
   enqueue_it(etree.tostring(myurl), collection_name)
   xx.wait_for_idle(collection=collection_name)

   #############################################################

   explist = ['http://moregarbage/moregarbage', 'http://garbage/']
   qstring = '({content} THRU {content}) OR ({content} THRU {content}) OR aclskipword'
   cs_pass += do_case(casenum=3, query=qstring, 
                      explist=explist, acluser=acluser, count=2)

   explist = ['http://moregarbage/moregarbage']
   qstring = '(aclskipword1 THRU aclskipword2) OR aclskipword'
   cs_pass += do_case(casenum=4, query=qstring, 
                      explist=explist, acluser=acluser, count=1)

   explist = ['http://moregarbage/moregarbage']
   qstring = '(aclskipword1 THRU "aclskipword2 aclskipword3") OR aclskipword'
   cs_pass += do_case(casenum=5, query=qstring, 
                      explist=explist, acluser=acluser, count=1)

   explist = ['http://moregarbage/moregarbage']
   qstring = '(aclskipword1 AND "aclskipword2 aclskipword3") OR aclskipword'
   cs_pass += do_case(casenum=6, query=qstring, 
                      explist=explist, acluser=acluser, count=1)

   explist = ['http://moregarbage/moregarbage', 'http://garbage/']
   qstring = '{document} OR aclskipword'
   cs_pass += do_case(casenum=7, query=qstring, 
                      explist=explist, acluser=acluser, count=2)

   explist = ['http://moregarbage/moregarbage', 'http://garbage/']
   qstring = '{document}'
   cs_pass += do_case(casenum=8, query=qstring, 
                      explist=explist, acluser=acluser, count=2)

   explist = ['http://moregarbage/moregarbage', 'http://garbage/']
   qstring = '{document} {content}'
   cs_pass += do_case(casenum=9, query=qstring, 
                      explist=explist, acluser=acluser, count=2)

   explist = []
   qstring = 'DOCUMENT_KEY:doc CONTAINING notaclskipword'
   cs_pass += do_case(casenum=10, query=qstring, 
                      explist=explist, acluser=acluser, count=0)

   explist = ['http://moregarbage/moregarbage']
   qstring = 'DOCUMENT_KEY:doc CONTAINING notaclskipword'
   cs_pass += do_case(casenum=11, query=qstring, 
                      explist=explist, acluser=None, count=1)

   explist = []
   qstring = 'notaclskipword WITHIN DOCUMENT_KEY:doc'
   cs_pass += do_case(casenum=12, query=qstring, 
                      explist=explist, acluser=acluser, count=0)

   explist = ['http://moregarbage/moregarbage']
   qstring = 'notaclskipword WITHIN DOCUMENT_KEY:doc'
   cs_pass += do_case(casenum=13, query=qstring, 
                      explist=explist, acluser=None, count=1)

   #############################################################

   if ( cs_pass == 26 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ": ", cs_pass, "of 26 checks passed."
   print tname, ":  Test Failed"
   sys.exit(1)

