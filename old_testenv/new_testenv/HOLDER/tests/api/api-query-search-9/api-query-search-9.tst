#!/usr/bin/python

#  <binning>
#    <binning-set bs-id="ship" label="myship" remove-state="">
#      <bin label="Battleship" ndocs="62" active="active" cndocs="62"/>
#    </binning-set>
#    <binning-state>
#      <binning-state-token bst-id="0" bs-id="ship" token="ship==Battleship" remove-state=""/>
#    </binning-state>
#  </binning>
#  <query>
#    <operator logic="and">
#      <term field="max" str="100" processing="optional" input-type="system"/>
#      <term field="v.binning-state" str="ship==Battleship" input-type="system"/>
#      <term field="v.binning-mode" str="normal" processing="optional" input-type="system"/>
#      <term field="v.collapse-binning" str="true"/>
#    </operator>
#  </query>
#

import sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   maxcount = 10
   i = 0
   cs_pass = 0
   casecount = 0
   num = 500
   clustercount = 10
   cluster = 'true'
   perpage = 10
   fail = 0

   tname = "api-query-search-9"
   collection_name = "aqs-9"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  query-search (test 5)"
   print tname, ":  Miscellaneous binning options"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()

   xx.create_collection(collection=collection_name, usedefcon=0)
   xx.start_crawl(collection=collection_name)

   thebeginning = time.time()
   xx.wait_for_idle(collection=collection_name)

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  TEST CASES BEGIN"


   print tname, ":  ##################"
   print tname, ":  CASE 1, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = default"
   casecount = casecount + 1
   bres = 62
   tres = 62
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  filename='bindef')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='bindef')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="bindef"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = off"
   casecount = casecount + 1
   bres = 0
   tres = 352
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  filename='binoff', binmode='off')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binoff')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binoff"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 3, query not supplied"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   bres = 62
   tres = 62
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  filename='binnorm', binmode='normal')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binnorm')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binnorm"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, query empty"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   tres = 62
   bres = 62
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  query='', filename='binall1', binmode='normal')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binall1')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binall1"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5, query Battleship OR Cruiser"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   bres = 62
   tres = 62
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  query='Battleship OR Cruiser',
                  filename='binall2', binmode='normal',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binall2')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="binall2"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 6, query Battleship"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   tres = 62
   bres = 62
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  query='Battleship', filename='bincr', binmode='normal',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='bincr')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="bincr"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 7, query Cruiser"
   print tname, ":     state ship==Battleship"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   bres = 0
   tres = 0
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battleship',
                  query='Cruiser', filename='bincrz', binmode='normal',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7, clustercount=0,
                                          perpage=0, num=0,
                                          tr=tres, testname=tname,
                                          filename='bincrz')

   bcnt = int(xx.count_bin_urls(value="Battleship", filenm="bincrz"))
   print tname, ":     URLs in bin Battleship"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 8, query Cruiser"
   print tname, ":     state ship==Cruiser"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   tres = 29
   bres = 29
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Cruiser',
                  query='Cruiser', filename='bincrz2', binmode='normal',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='bincrz2')

   bcnt = int(xx.count_bin_urls(value="Cruiser", filenm="bincrz2"))
   print tname, ":     URLs in bin Cruiser"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 9, query Cruiser"
   print tname, ":     state ship==Battlecruiser"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   bres = 0
   tres = 0
   yy.api_qsearch(xx=xx, source=collection_name, binstate='ship==Battlecruiser',
                  query='Cruiser', filename='bincrz3', binmode='normal',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9, clustercount=0,
                                          perpage=0, num=0,
                                          tr=tres, testname=tname,
                                          filename='bincrz3')

   bcnt = int(xx.count_bin_urls(value="Battlecruiser", filenm="bincrz3"))
   print tname, ":     URLs in bin Battlecruiser"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 10, query Aircraft Carrier"
   print tname, ":     state ship==Aircraft Carrier"
   print tname, ":     mode = normal"
   casecount = casecount + 1
   bres = 50
   breslc = 1
   bresnac = 1
   tres = 50
   yy.api_qsearch(xx=xx, source=collection_name,
                  binstate='ship==Aircraft Carrier',
                  query='Aircraft Carrier', filename='binac1',
                  binmode='normal',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binac1')

   bcnt = int(xx.count_bin_urls(value="\'Aircraft Carrier\'", filenm="binac1"))
   print tname, ":     URLs in bin Aircraft Carrier"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   bcnt = int(xx.count_bin_urls(value="\'Light Cruiser\'", filenm="binac1"))
   print tname, ":     URLs in bin Light Cruiser"
   print tname, ":        Expected", breslc
   print tname, ":        Actual  ", bcnt
   if ( bcnt != breslc ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   bcnt = int(xx.count_bin_urls(value="\'Nuclear Aircraft Carrier\'", filenm="binac1"))
   print tname, ":     URLs in bin Nuclear Aircraft Carrier"
   print tname, ":        Expected", bresnac
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bresnac ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 11, query Aircraft Carrier"
   print tname, ":     state ship==Aircraft Carrier"
   print tname, ":     mode = off"
   casecount = casecount + 1
   bres = 0
   tres = 100
   yy.api_qsearch(xx=xx, source=collection_name,
                  binstate='ship==Aircraft Carrier',
                  query='Aircraft Carrier', filename='binac2',
                  binmode='off',
                  bincol='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binac2')

   bcnt = int(xx.count_bin_urls(value="\'Aircraft Carrier\'", filenm="binac2"))
   print tname, ":     URLs in bin Aircraft Carrier"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 12, query Aircraft Carrier"
   print tname, ":     state ship==Aircraft Carrier"
   print tname, ":     mode = double"
   casecount = casecount + 1
   tres = 50
   bres = 50
   yy.api_qsearch(xx=xx, source=collection_name,
                  binstate='ship==Aircraft Carrier',
                  query='Aircraft Carrier', filename='binac3',
                  binmode='double',
                  bincol='false')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=12, clustercount=0,
                                          perpage=10, num=10,
                                          tr=tres, testname=tname,
                                          filename='binac3')

   bcnt = int(xx.count_bin_urls(value="\'Aircraft Carrier\'", filenm="binac3"))
   print tname, ":     URLs in bin Aircraft Carrier"
   print tname, ":        Expected", bres
   print tname, ":        Actual  ", bcnt
   if ( bcnt != bres ):
      fail = fail + 1
      print tname, ":  Wrong number binning urls or bin label missing"
   print tname, ":  ##################"

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == casecount and fail == 0 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
