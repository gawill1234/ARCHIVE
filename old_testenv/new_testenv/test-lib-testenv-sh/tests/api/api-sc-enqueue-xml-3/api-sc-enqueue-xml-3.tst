#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
import gen_content
from lxml import etree

def do_crawl_urls(crawl_urls=None, doc_count=20, startpoint=0):

   text = ''

   letter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

   myurl = gen_content.gen_url(num='%s' % startpoint)
   crawl_urls = build_schema_node.create_crawl_urls()
   crawl_url = build_schema_node.create_crawl_url(url=myurl,
               status='complete', enqueuetype='forced',
               synchronization='indexed-no-sync', addnodeto=crawl_urls)
   curlopts = build_schema_node.create_curl_options(addnodeto=crawl_url)
   curlopt = build_schema_node.create_curl_option(addnodeto=curlopts,
                                name='default-allow',
                                added='added',
                                text='allow')
   curlopt = build_schema_node.create_curl_option(addnodeto=curlopts,
                                name='max-hops',
                                added='added',
                                text='1')
   crawl_data = build_schema_node.create_crawl_data(encoding='xml',
                contenttype='application/vxml-unnormalized',
                addnodeto=crawl_url)

   vcenode = build_schema_node.create_vce(addnodeto=crawl_data)
   dcollect = gen_content.gen_docs(doc_count=doc_count)


   i = 0
   for doc in dcollect.docs():
      #print "=================================================="
      #print doc
      #print "=================================================="

      myurl = gen_content.gen_url(num='%s' % startpoint, letterpart=letter[i])
      #print "MYURL:  ", myurl
      adoc = build_schema_node.create_document(url=myurl, addnodeto=vcenode)

      gen_content.do_content_nodes(addnodesto=adoc,
                                   cnamenum='%s' % startpoint, text=doc)

      i += 1

   return crawl_urls

def do_enqueues(howmany=10000, collection_name2=None):

   count = 0
   alldocs = 0

   while ( count < howmany ):

       count += 1
       alldocs += 20

       #print "============================= "
       crawl_urls = do_crawl_urls(startpoint=count)
       #print "============================="
       resp = yy.api_sc_enqueue_xml(
                        collection=collection_name2,
                        subc='live',
                        crawl_nodes=etree.tostring(crawl_urls))
       #print etree.tostring(crawl_urls)

   print "DOCUMENTS ENQUEUED (final):  ", alldocs

   return alldocs


if __name__ == "__main__":

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 1

   collection_name2 = "scex-3"
   tname = "api-sc-enqueue-xml-3"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  audit logs test 1"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Create empty collection", collection_name2
   #
   #   Empty collection to be filled using crawl-urls
   #
   cex = xx.collection_exists(collection=collection_name2)
   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name2)

   yy.api_sc_create(collection=collection_name2, based_on='default-push')

   thebeginning = time.time()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"

   filecount = do_enqueues(howmany=1000, collection_name2=collection_name2)

   xx.wait_for_idle(collection=collection_name2)

   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   print tname, ":  ##################"


   if ( filecount != indexedcount ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  filecount     = ", filecount
   else:
      print tname, ":  total results and filecount are correct at ", filecount
      fail = 0

   ##############################################################

   #xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
