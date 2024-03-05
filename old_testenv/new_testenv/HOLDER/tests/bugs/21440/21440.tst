#!/usr/bin/python

import os, sys, time, cgi_interface, vapi_interface, tc_generic
import random
import build_schema_node
from lxml import etree

myurl = \
'<crawl-urls> \
  <crawl-url enqueue-type="reenqueued" status="complete" url="Item1" synchronization="indexed-no-sync"> \
    <crawl-data content-type="application/vxml-unnormalized"> \
      <vxml> \
        <document vse-key="Item1" vse-key-normalized="vse-key-normalized"> \
          <advanced-content> \
            <content name="ssid" type="text" add-to="Item1" vse-add-to-normalized="vse-add-to-normalized">saveset~IDx~23.1</content> \
            <vse-index-stream stem="none" delanguage="false"> \
              <vse-tokenizer name="literal"/> \
            </vse-index-stream> \
          </advanced-content> \
          <advanced-content> \
            <content name="subj" type="text" add-to="Item1" vse-add-to-normalized="vse-add-to-normalized" vse-streams="0">What</content> \
          </advanced-content> \
          <advanced-content> \
            <content name="snum" weight="-1" add-to="Item1" vse-add-to-normalized="vse-add-to-normalized" indexed-fast-index="int" vse-streams="0">10</content> \
          </advanced-content> \
        </document> \
      </vxml> \
    </crawl-data> \
  </crawl-url> \
  <crawl-url enqueue-type="reenqueued" status="complete" url="Item1#pvid" synchronization="indexed-no-sync"> \
    <crawl-data content-type="application/vxml-unnormalized"> \
      <vxml> \
        <advanced-content> \
          <content name="pvid" type="text" add-to="Item1" vse-add-to-normalized="vse-add-to-normalized" vse-streams="0">Where</content> \
        </advanced-content> \
      </vxml> \
    </crawl-data> \
  </crawl-url> \
  <crawl-url enqueue-type="reenqueued" status="complete" url="Item1#rcat" synchronization="indexed-no-sync"> \
    <crawl-data content-type="application/vxml-unnormalized"> \
      <vxml> \
        <advanced-content> \
          <content name="rcat" type="text" add-to="Item1" vse-add-to-normalized="vse-add-to-normalized" vse-streams="0">HowLong</content> \
        </advanced-content> \
      </vxml> \
    </crawl-data> \
  </crawl-url> \
</crawl-urls>'

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
   
   collection_name = "21440"
   tname = "21440"
   
   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":     test for bug 21440"
   
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

   explist = ['http://127.0.0.1:7205/Item1']

   enqueue_it(myurl, collection_name)
   xx.wait_for_idle(collection=collection_name)

   resp = yy.api_qsearch(source=collection_name,
                         query='What',
                         filename='what')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=1, num=1, filename='what',
                      testname=tname)

   filename = yy.look_for_file(filename='what')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   explist = ['http://127.0.0.1:7205/Item1']

   resp = yy.api_qsearch(source=collection_name,
                         query='Where',
                         filename='where')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=1, num=1, filename='where',
                      testname=tname)

   filename = yy.look_for_file(filename='where')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   explist = ['http://127.0.0.1:7205/Item1']

   resp = yy.api_qsearch(source=collection_name,
                         query='HowLong',
                         filename='howlong')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=1, num=1, filename='howlong',
                      testname=tname)

   filename = yy.look_for_file(filename='howlong')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   print urllist

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   #############################################################

   if ( cs_pass == 6 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)

