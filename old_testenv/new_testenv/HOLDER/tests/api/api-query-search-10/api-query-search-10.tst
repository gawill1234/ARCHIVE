#!/usr/bin/python


import sys, time, cgi_interface, vapi_interface, tc_generic 

if __name__ == "__main__":

   maxcount = 10
   i = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 0
   casecount = 0
   cs_pass = 0

   collection_name1 = "aqs-10a"
   collection_name1dup = "aqs-10adup"
   collection_name2 = "aqs-10b"
   collection_name3 = "aqs-10db"
   sourcelist = "aqs-10a aqs-10db aqs-10b"
   duplist = "aqs-10a aqs-10adup"
   tname = "api-query-search-10"

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  query-search (test 10)"
   print tname, ":     Multi-collection crawl/aggregation with binning"
   print tname, ":     query multiple collections at the same time"
   print tname, ":     with and without aggregation"
   print tname, ":  Search is done on 2, 3 or 4 collections"
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

   print tname, ":     Crawl collection", collection_name1dup
   #
   #   Samba collection
   #
   xx.create_collection(collection=collection_name1dup, usedefcon=0)
   xx.start_crawl(collection=collection_name1dup)
   xx.wait_for_idle(collection=collection_name1dup)

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
   print tname, ":  CASE 1, query Battleship"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     single collection with binning"
   casecount = casecount + 1
   bres = 62
   tres = 62
   yy.api_qsearch(xx=xx, source=collection_name1, binstate='ship==Battleship',
                  filename='qbtl1', query='Battleship', num=100)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=bres, num=bres,
                                          tr=tres, testname=tname,
                                          filename='qbtl1')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="qbtl1"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, query Battleship"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     single collection with binning"
   casecount = casecount + 1
   bres = 62
   tres = 62
   yy.api_qsearch(xx=xx, source=collection_name2, binstate='ship==Battleship',
                  filename='qbtl2', query='Battleship', num=100)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=bres, num=bres,
                                          tr=tres, testname=tname,
                                          filename='qbtl2')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="qbtl2"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 3, query Battleship"
   print tname, ":     mode = default"
   print tname, ":     single collection without binning"
   casecount = casecount + 1
   tres = 66
   yy.api_qsearch(xx=xx, source=collection_name3,
                  filename='qbtl3', query='Battleship', num=100)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                                          perpage=tres, num=tres,
                                          tr=tres, testname=tname,
                                          filename='qbtl3')

   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     aggregate = off/default"
   print tname, ":     3 collections"
   casecount = casecount + 1
   bres = 124
   tres = 124
   yy.api_qsearch(xx=xx, source=sourcelist, binstate='ship==Battleship',
                  filename='bindef', num=100)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=88, num=88,
                                          tr=tres, testname=tname,
                                          filename='bindef',
                                          multibinning='true')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="bindef"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     aggregate = true"
   print tname, ":     3 collections"
   casecount = casecount + 1
   bres = 62
   tres = 124
   yy.api_qsearch(xx=xx, source=sourcelist, binstate='ship==Battleship',
                  filename='binaggr', aggr='true', num=100)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=bres, num=bres,
                                          tr=tres, testname=tname,
                                          filename='binaggr',
                                          multibinning='true')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binaggr"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres * 2
   print tname, ":        Actual  ", bcnt
   if ( bcnt != (bres * 2) ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 6, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     aggregate = true"
   print tname, ":     2 collections which are exact duplicates"
   casecount = casecount + 1
   bres = 62
   tres = 124
   yy.api_qsearch(xx=xx, source=duplist, binstate='ship==Battleship',
                  filename='binaggrdup', aggr='true', num=100)

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=bres, num=bres,
                                          tr=tres, testname=tname,
                                          filename='binaggrdup',
                                          multibinning='true')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binaggrdup"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres * 2
   print tname, ":        Actual  ", bcnt
   if ( bcnt != (bres * 2) ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 7, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     aggregate = true"
   print tname, ":     output-duplicates = true"
   print tname, ":     3 collections"
   casecount = casecount + 1
   bres = 62
   tres = 124
   yy.api_qsearch(xx=xx, source=sourcelist, binstate='ship==Battleship',
                  filename='binaggrdup', aggr='true', num=100, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=bres, num=bres,
                                          tr=tres, testname=tname,
                                          filename='binaggrdup',
                                          multibinning='true')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binaggrdup"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres * 2
   print tname, ":        Actual  ", bcnt
   if ( bcnt != (bres * 2) ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 8, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   print tname, ":     aggregate = true"
   print tname, ":     output-duplicates = true"
   print tname, ":     2 collections which are exact duplicates"
   casecount = casecount + 1
   bres = 62
   tres = 124
   yy.api_qsearch(xx=xx, source=duplist, binstate='ship==Battleship',
                  filename='binaggrdup', aggr='true', num=100, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=bres, num=bres,
                                          tr=tres, testname=tname,
                                          filename='binaggrdup',
                                          multibinning='true')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binaggrdup"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres * 2
   print tname, ":        Actual  ", bcnt
   if ( bcnt != (bres * 2) ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( fail == 0  and cs_pass == casecount ):
      xx.delete_collection(collection=collection_name1)
      xx.delete_collection(collection=collection_name2)
      xx.delete_collection(collection=collection_name3)
      xx.delete_collection(collection=collection_name1dup)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
