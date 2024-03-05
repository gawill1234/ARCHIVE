#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface, tc_generic

def isInList(checkfor, thelist):

   m = 0

   for item in thelist:
      if ( item == checkfor ):
         m = m+1

   if (m > 1):
      print "Appears more than once (", m, " times): ", checkfor

   if (m > 0):
      return 1

   return 0

def doDumpListInfo(currentdata, expecteddata):

   for item in currentdata:
      if ( isInList(item, expecteddata) != 1 ):
         print "Missing from expected data, in current data:", item

   for item in expecteddata:
      if ( isInList(item, currentdata) != 1 ):
         print "Missing from current data, in expected data:", item

   return

if __name__ == "__main__":

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 0

   collection_name1 = "aqs-8a"
   collection_name2 = "aqs-8b"
   collection_name3 = "aqs-8db"
   sourcelist = "aqs-8a aqs-8db aqs-8b"
   tname = "api-query-search-8"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  query-search (test 8)"
   print tname, ":     Multi-collection crawl/aggregation"
   print tname, ":     query multiple collections at the same time"
   print tname, ":     with and without aggregation"
   print tname, ":  Search is done on 3 collections"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   zz = tc_generic.TCINTERFACE()

   print tname, ":  PERFORM CRAWLS"
   print tname, ":     Crawl collection", collection_name1
   #
   #   Samba collection
   #
   xx.create_collection(collection=collection_name1, usedefcon=0)
   xx.start_crawl(collection=collection_name1)
   xx.wait_for_idle(collection=collection_name1)

   print tname, ":     Crawl collection", collection_name2
   #
   #   Samba collection (duplicate of above, yes I need it)
   #
   xx.create_collection(collection=collection_name2, usedefcon=0)
   xx.start_crawl(collection=collection_name2)
   xx.wait_for_idle(collection=collection_name2)

   print tname, ":     Crawl collection", collection_name3
   #
   #   DB collection
   #
   xx.create_collection(collection=collection_name3, usedefcon=0)
   xx.start_crawl(collection=collection_name3)
   xx.wait_for_idle(collection=collection_name3)
   print tname, ":  CRAWLS COMPLETE"

   thebeginning = time.time()

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  CASE 1, DEFAULTS"
   print tname, ":     output-contents-mode = defaults"
   print tname, ":     output-contents = <empty>"

   yy.api_qsearch(xx=xx, source=sourcelist, query='', num_ovr_req=10,
                  num=600, filename='defaults', aggrmaxpass=10)
   cnt1 = int(yy.get_doc_attr_count(xx=xx, filename='defaults', item='url'))

   def2res = yy.api_qsearch(xx=xx, source=sourcelist, query='', num_ovr_req=10,
                  aggr='true', oscore='true', oshing='true',
                  okey='true', osortkey='true', num=600,
                  filename='defaults2', aggrmaxpass=10)
   cnt2 = int(yy.get_doc_attr_count(xx=xx, filename='defaults2', item='url'))
   def2cur = yy.getResultUrls(filename='defaults2')
   def2exp = yy.getResultUrls(filename='compare_data/defaults2.wazzat')

   def3res = yy.api_qsearch(xx=xx, source=sourcelist, query='', num_ovr_req=10,
                  aggr='true', num=600,
                  filename='defaults3', aggrmaxpass=10)
   cnt3 = int(yy.get_doc_attr_count(xx=xx, filename='defaults3', item='url'))
   def3cur = yy.getResultUrls(filename='defaults3')
   def3exp = yy.getResultUrls(filename='compare_data/defaults3.wazzat')

   yy.api_qsearch(xx=xx, source=sourcelist, query='', num_ovr_req=10,
                  aggr='false', num=600,
                  filename='defaults4', aggrmaxpass=10)
   cnt4 = int(yy.get_doc_attr_count(xx=xx, filename='defaults4', item='url'))

   yy.api_qsearch(xx=xx, source=sourcelist, query='', num_ovr_req=10,
                  aggr='false', num=600, odup='true',
                  filename='defaults5', aggrmaxpass=10)
   cnt5 = int(yy.get_doc_attr_count(xx=xx, filename='defaults5', item='url'))

   print tname, ":  Basic query of multiple collections"
   print tname, ":     Expected 444"
   print tname, ":     Actual(1),", cnt1
   print tname, ":     Actual(2),", cnt4
   if ( cnt1 == cnt4 and cnt1 == 444 ):
      print tname, ":  Basic query succeeded"
   else:
      print tname, ":  Basic query failed"
      fail = fail + 1

   if ( yy.TENV.targetos == "solaris" ):
      thisval = 395
   else:
      thisval = 398

   print tname, ":  Basic query of aggregated collections"
   print tname, ":     Expected", thisval
   print tname, ":     Actual(1),", cnt2
   print tname, ":     Actual(2),", cnt3
   print "Data differences:"
   doDumpListInfo(def3cur, def3exp)
   doDumpListInfo(def2cur, def2exp)

   if ( cnt2 == cnt3 and cnt3 == thisval ):
      print tname, ":  Aggregation succeeded"
   else:
      print tname, ":  Aggregation failed"
      fail = fail + 1

   print tname, ":  Basic query of multiple collections with dups"
   print tname, ":     Expected 446"
   print tname, ":     Actual,", cnt5
   if ( cnt5 == 446 ):
      print tname, ":  Dups properly accounted for"
   else:
      print tname, ":  Dup addition failed"
      fail = fail + 1

   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( fail == 0 ):
      xx.delete_collection(collection=collection_name1)
      xx.delete_collection(collection=collection_name2)
      xx.delete_collection(collection=collection_name3)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
