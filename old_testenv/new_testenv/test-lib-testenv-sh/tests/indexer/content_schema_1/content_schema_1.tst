#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
from lxml import etree

def do_crawl_urls(filename=None, urlnum=0):

   myurl = 'http://vivisimo_' + '%s' % urlnum + '.com'
   crawl_urls = build_schema_node.create_crawl_urls()
   crawl_url = build_schema_node.create_crawl_url(url=myurl,
               status='complete', enqueuetype='reenqueued',
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
   crawl_data = build_schema_node.create_crawl_data(encoding='utf-8',
                contenttype='application/vxml-unnormalized',
                addnodeto=crawl_url, filename=filename)

   return crawl_urls

def do_enqueues(collection_name2=None, directory=None, filelist=None):

   z = 0

   for item in filelist:

       filetoread = directory + '/' + item

       print tname, ": ============================= "
       print tname, ": Enqueuing: ", filetoread
       crawl_urls = do_crawl_urls(filename=filetoread, urlnum=z)
       #print etree.tostring(crawl_urls)
       print tname, ": ============================="
       resp = yy.api_sc_enqueue_xml(
                        collection=collection_name2,
                        subc='live',
                        crawl_nodes=etree.tostring(crawl_urls))
       z += 1

   return z


if __name__ == "__main__":

   fail = 0

   collection_name2 = "cntnt_schm_1"
   tname = "content_schema_1"

   datadir = 'content_schema_data'
   datafiles = ['csn-1.vxml', 'csn-2.vxml', 'csn-3.vxml', 'csn-4.vxml',
                'csn-5.vxml', 'csn-6.vxml', 'csn-7.vxml', 'csn-8.vxml',
                'csn-9.vxml', 'csn-10.vxml', 'csn-11.vxml']

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  content schema node test 1"

   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   if ( xx.TENV.vivfloatversion < 7.5 ):
      print tname, ":  Unsupported release for these features"
      sys.exit(0)

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

   filecount = do_enqueues(collection_name2=collection_name2,
                           directory=datadir, filelist=datafiles)

   xx.wait_for_idle(collection=collection_name2)

   ##############################################################
   print tname, ": #############################################"
   print tname, ":  Blank Query Test Case"
   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='',
                         ocmode='except', oclist='size snippet',
                         osumtf='false', filename='blank_query')

   #
   #   This should be valid as there should be no dups on my file list.
   #
   indexedcount = yy.getTotalResults(resptree=resp)

   clustercount = yy.getResultGenericTagCount(resptree=resp,
                                     tagname="content",
                                     attrname="action",
                                     attrvalue="cluster")
   eicluster = 8

   if ( filecount != indexedcount ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", indexedcount
      print tname, ":  filecount     = ", filecount
      fail += 1
   else:
      print tname, ":  total results and filecount are correct at ", filecount

   if ( clustercount != eicluster ):
      print tname, ":  total cluster results differ"
      print tname, ":  total cluster results = ", clustercount
      print tname, ":  expected cluster result = ", eicluster
      fail += 1
   else:
      print tname, ":  total results cluster count correct at ", clustercount

   ##############################################################
   print tname, ": #############################################"
   print tname, ":  German Query Test Case(queryable term deutsch)"
   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='deutsch',
                         ocmode='except', oclist='size snippet',
                         osumtf='false', filename='german_query')

   germancount = yy.getTotalResults(resptree=resp)
   clustercount = yy.getResultGenericTagCount(resptree=resp,
                                     tagname="content",
                                     attrname="action",
                                     attrvalue="cluster")
   egc = 5
   egcluster = 4
   if ( germancount != egc ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", germancount
      print tname, ":  filecount     = ", egc
      fail += 1
   else:
      print tname, ":  german query results are correct at ", egc

   if ( clustercount != egcluster ):
      print tname, ":  total cluster results differ"
      print tname, ":  total cluster results = ", clustercount
      print tname, ":  expected cluster result = ", egcluster
      fail += 1
   else:
      print tname, ":  german results cluster count correct at ", clustercount

   ##############################################################
   print tname, ": #############################################"
   print tname, ":  Spanish Query Test Case(not queryable term espanol)"
   resp = yy.api_qsearch(xx=xx, source=collection_name2, query='espanol',
                         ocmode='except', oclist='size snippet',
                         osumtf='false', filename='spanish_query')

   spanishcount = yy.getTotalResults(resptree=resp)
   clustercount = yy.getResultGenericTagCount(resptree=resp,
                                     tagname="content",
                                     attrname="action",
                                     attrvalue="cluster")
   sgc = 0
   escluster = 0
   if ( spanishcount != sgc ):
      print tname, ":  total results and filecount differ"
      print tname, ":  total results = ", spanishcount
      print tname, ":  filecount     = ", sgc
      fail += 1
   else:
      print tname, ":  spanish query results are correct at ", sgc

   if ( clustercount != escluster ):
      print tname, ":  total cluster results differ"
      print tname, ":  total cluster results = ", clustercount
      print tname, ":  expected cluster result = ", escluster
      fail += 1
   else:
      print tname, ":  spanish results cluster count correct at ", clustercount

   ##############################################################
   print tname, ": #############################################"
   print tname, ":  Final Result"

   xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
