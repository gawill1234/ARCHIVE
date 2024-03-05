#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic 
import build_schema_node
from lxml import etree

def correct_results_by_qid(qid=None, qidresults=[]):

   found = True

   if ( qid == 'ALL' ):
      return found

   for item in qidresults:
      qidlist = item.split('::')
      sfound = False
      for sngle_qid in qidlist:
         if ( sngle_qid == qid ):
            sfound = True
      if ( not sfound ):
         found = False

   return found

def result_check(tname, qid, my_query, my_count, indexedcount, qidlist):

   fail = False

   print tname, ":   Results check for query:", my_query
   print tname, ":                     qid  :", qid

   print tname, ":   Found", indexedcount, "results"
   print tname, ":   Expected", my_count, "results"
   if ( int(my_count) != int(indexedcount) ):
      print tname, ":   Fail:  Incorrect number of results"
      fail = True

   if ( int(indexedcount) > 0 ):
      if ( correct_results_by_qid(qid=qid, qidresults=qidlist) ):
         print tname, ":   All returned results match query id", qid
      else:
         print tname, ":   Fail:  Some returned results do not match query id", qid
         fail = True
   else:
         print tname, ":   Id check not done, no results found"

   if ( not fail ):
      print tname, ":   Case Passed"
   else:
      print tname, ":   Case Failed"


   return fail

def get_query_info(query_data_list=None):

   qids = []
   queries = {}
   qcounts = {}

   for qitem in query_data_list:
      qseglist = qitem.split('||')
      for segitem in qseglist:
         print "SEGITEM:", segitem
         qsinglelist = segitem.split('::')
         realqid = qsinglelist[2].split('=')[1]
         realcount = qsinglelist[1].split('=')[1]
         realquery = qsinglelist[0].split('=')[1]
         try:
            qcounts[realqid] = qcounts[realqid] + int(realcount)
         except KeyError:
            qcounts[realqid] = int(realcount)
            queries[realqid] = realquery
            qids.append(realqid)

   #for item in qids:
   #   print item, queries[item], qcounts[item]

   return qids, queries, qcounts

def get_query_list_data(resp=None, thing=None):

   messylist = []

   for elt in resp.getiterator('content'):
      if ( elt.attrib.has_key('name') ):
         if ( elt.get('name') == thing ):
            try:
               zzz = elt.findtext('.', default=None)
               if ( zzz is not None ):
                  messylist.append(zzz)
            except:
               print "Error, SHIT!!!"

   return  messylist

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

   collection_name2 = "many-languages"
   tname = "language_indifferent-1"

   datadir = 'vxml_data'
   datafiles = ['working.vxml']
   #datafiles = ['english-1.vxml','spanish-1.vxml', 'japanese-1.vxml',
   #             'jn-strng-doc1.vxml', 'jn-strng-doc2.vxml', 
   #             'jn-strng-doc3.vxml', 'jn-strng-doc4.vxml',
   #             'jn-strng-doc5.vxml', 'jn-strng-doc6.vxml',
   #             'jn-strng-doc7.vxml', 'jn-strng-doc8.vxml',
   #             'jn-strng-doc9.vxml', 'jn-strng-doc10.vxml',
   #             'jn-strng-doc11.vxml', 'jn-strng-doc12.vxml',
   #             'jn-strng-doc13.vxml', 'jn-strng-doc14.vxml',
   #             'jn-strng-doc15.vxml', 'jn-strng-doc16.vxml',
   #             'jn-strng-doc17.vxml', 'jn-strng-doc18.vxml',
   #             'jn-strng-doc19.vxml', 'jn-strng-doc20.vxml',
   #             'jn-strng-doc21.vxml', 'jn-strng-doc22.vxml',
   #             'jn-strng-doc23.vxml', 'jn-strng-doc24.vxml',
   #             'jn-strng-doc25.vxml', 'jn-strng-doc26.vxml',
   #             'jn-strng-doc27.vxml', 'jn-strng-doc28.vxml',
   #             'jn-strng-doc29.vxml', 'jn-strng-doc30.vxml',
   #             'jn-strng-doc31.vxml', 'jn-strng-doc32.vxml',
   #             'jn-strng-doc33.vxml', 'jn-strng-doc34.vxml',
   #             'jn-strng-doc35.vxml', 'jn-strng-doc36.vxml',
   #             'jn-strng-doc37.vxml', 'jn-strng-doc38.vxml',
   #             'jn-strng-doc39.vxml', 'jn-strng-doc40.vxml',
   #             'jn-strng-doc41.vxml', 'jn-strng-doc42.vxml',
   #             'jn-strng-doc43.vxml', 'jn-strng-doc44.vxml',
   #             'jn-strng-doc45.vxml', 'jn-strng-doc46.vxml',
   #             'jn-strng-doc47.vxml', 'jn-strng-doc48.vxml',
   #             'jn-strng-doc49.vxml']
                #'jn-strng-doc49.vxml', 'jn-strng-doc50.vxml']

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
   resp = yy.api_qsearch(xx=xx, source=collection_name2,
                         query='title:query-data', filename='dump1', num=200)
   qdstrlst = get_query_list_data(resp=resp, thing='query-data')
   qids, queries, qcounts = get_query_info(query_data_list=qdstrlst)

   failing = 0
   passing = 0
   case_count = 1
   for qid in qids:
      print tname, ": =============================================="
      print tname, ":   Case", case_count
      my_query = queries[qid]
      my_count = qcounts[qid]
      my_file = qid

      if ( qid == 'ALL' ):
         qstring = ''
      else:
         qstring = ''.join(['title:', my_query])

      resp = yy.api_qsearch(xx=xx, source=collection_name2,
                            query=qstring, filename=my_file, num=200)
      qidlist = get_query_list_data(resp=resp, thing='qid-list')
      indexedcount = yy.getTotalResults(resptree=resp)
      if ( result_check(tname, qid, my_query, my_count, indexedcount, qidlist) ):
         passing += 1
      else:
         failing += 1
      print tname, ": =============================================="
      case_count += 1

   xx.dump_indices(collectionname=collection_name2)

   ##############################################################
   print tname, ": #############################################"
   print tname, ":  Final Result"

   if ( failing == 0 and passing == case_count ):
      xx.delete_collection(collection=collection_name2)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
