#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface


if __name__ == "__main__":

   collection_name = "literal-search-5"
   tname = 'literal-search-5'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Regular expression queries"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.5)

   cex = xx.collection_exists(collection=collection_name)

   if ( cex == 1 ):
      print tname, ":  Old collection exists.  Deleting."
      yy.api_sc_crawler_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_indexer_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_delete(xx=xx, collection=collection_name)
      cex = xx.collection_exists(collection=collection_name)
      if ( cex == 1 ):
         print tname, ":  Old collection still exists.  Trying to continue."

   if ( cex != 1 ):
      print tname, ":  Create and check the base collection"
      xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  #######################################"
   print tname, ":  Literal search using content level tokenizers"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":     at sign @ query should be parsed as one symbol ref"
   explist = ['http://vivisimo.com?email1',
              'http://vivisimo.com?email4']
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='@',
                       filename='atsign')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=2, num=2, filename='atsign',
                      testname=tname)

   filename = yy.look_for_file(filename='atsign')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 2"
   print tname, ":     email address query, jeff.skilling@enron.com"
   print tname, ":     appears in words and as separate bits"

   explist = ['http://vivisimo.com?email1', 
              'http://vivisimo.com?email3',
              'http://vivisimo.com?email4']
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='財.指@書.com',
                       filename='email1')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
                      clustercount=0, perpage=3, num=3, filename='email1',
                      testname=tname)

   filename = yy.look_for_file(filename='email1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"


   print tname, ":  #######################################"
   print tname, ":  CASE 3"
   print tname, ":     email address query, skilling@enron.com"
   print tname, ":     appears only as separate bits"
   print tname, ":     should not appear where symbols are part of words"

   explist = ['http://vivisimo.com?email1', 
              'http://vivisimo.com?email3',
              'http://vivisimo.com?email4']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='指@書.com',
                       filename='email2')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=3, num=3, filename='email2',
                      testname=tname)

   filename = yy.look_for_file(filename='email2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 4"
   print tname, ":     email address query, skilling"

   explist = ['http://vivisimo.com?email1', 
              'http://vivisimo.com?email3',
              'http://vivisimo.com?email4']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='指',
                       filename='email3')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=3, num=3, filename='email3',
                      testname=tname)

   filename = yy.look_for_file(filename='email3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 5"
   print tname, ":     email address query, jeff_skilling@enron.com"

   explist = ['http://vivisimo.com?email4', 
              'http://vivisimo.com?email3'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='財_指@書.com',
                       filename='email4', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                      clustercount=0, perpage=2, num=2, filename='email4',
                      testname=tname)

   filename = yy.look_for_file(filename='email4')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 6"
   print tname, ":     hypen in word, fizzy-lifting-drink"
   print tname, ":     All occurences should appear."

   explist = ['http://vivisimo.com?fizz1', 
              'http://vivisimo.com?fizz2',
              'http://vivisimo.com?fizz3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='入-に-か',
                       filename='fizzy1', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                      clustercount=0, perpage=3, num=3, filename='fizzy1',
                      testname=tname)

   filename = yy.look_for_file(filename='fizzy1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 7"
   print tname, ":     part of hypen in word, lifting"
   print tname, ":     appears only as separate bits"
   print tname, ":     should not appear where symbols are part of words"

   explist = ['http://vivisimo.com?fizz2', 
              'http://vivisimo.com?fizz3',
              'http://vivisimo.com?fizz1',
              'http://vivisimo.com?gl1',
              'http://vivisimo.com?lp1']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='に',
                       filename='fizzy2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7,
                      clustercount=0, perpage=5, num=5, filename='fizzy2',
                      testname=tname)

   filename = yy.look_for_file(filename='fizzy2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 8"
   print tname, ":     part of email, enron.com"
   print tname, ":     appears only as separate bits"
   print tname, ":     should not appear where symbols are part of words"

   explist = ['http://vivisimo.com?email4', 
              'http://vivisimo.com?email3',
              'http://vivisimo.com?email2',
              'http://vivisimo.com?email1']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='書.com',
                       filename='emailpart', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8,
                      clustercount=0, perpage=4, num=4, filename='emailpart',
                      testname=tname)

   filename = yy.look_for_file(filename='emailpart')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 9"
   print tname, ":     ssn, 987-65-4321"

   explist = ['http://vivisimo.com?ssn1',
              'http://vivisimo.com?ssn2'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='987-65-4321',
                       filename='ssn1', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9,
                      clustercount=0, perpage=2, num=2, filename='ssn1',
                      testname=tname)

   filename = yy.look_for_file(filename='ssn1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 10"
   print tname, ":     ssn, 987"
   print tname, ":     Should get no results"

   explist = ['http://vivisimo.com?ssn1']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='987',
                       filename='ssn2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10,
                      clustercount=0, perpage=1, num=1, filename='ssn2',
                      testname=tname)

   filename = yy.look_for_file(filename='ssn2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 11"
   print tname, ":     license plate, abc-1111"

   explist = ['http://vivisimo.com?lp1'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='入にか-1111',
                       filename='lp1', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=11,
                      clustercount=0, perpage=1, num=1, filename='lp1',
                      testname=tname)

   filename = yy.look_for_file(filename='lp1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 12"
   print tname, ":     license plate, spc 2222"

   explist = ['http://vivisimo.com?lp2'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='金繰 2222',
                       filename='lp2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=12,
                      clustercount=0, perpage=1, num=1, filename='lp2',
                      testname=tname)

   filename = yy.look_for_file(filename='lp2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 13"
   print tname, ":     license plate, qtm?3333"

   explist = ['http://vivisimo.com?lp3'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='資資金-3333',
                       filename='lp3', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=13,
                      clustercount=0, perpage=1, num=1, filename='lp3',
                      testname=tname)

   filename = yy.look_for_file(filename='lp3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 14"
   print tname, ":     miscellaneous, @@@"

   explist = [] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='@@@',
                       filename='misc1', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=14,
                      clustercount=0, perpage=0, num=0, filename='misc1',
                      testname=tname)

   filename = yy.look_for_file(filename='misc1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 15"
   print tname, ":     miscellaneous, @()"

   explist = [] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='@()',
                       filename='misc2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=15,
                      clustercount=0, perpage=0, num=0, filename='misc2',
                      testname=tname)

   filename = yy.look_for_file(filename='misc2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 16"
   print tname, ":     half size query"

   explist = ['http://vivisimo.com?halffullmix',
              'http://vivisimo.com?halfwidth'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ﾓｶﾇ',
                       filename='halfqry', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=16,
                      clustercount=0, perpage=2, num=2, filename='halfqry',
                      testname=tname)

   filename = yy.look_for_file(filename='halfqry')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 17"
   print tname, ":     half size query"

   explist = ['http://vivisimo.com?halffullmix',
              'http://vivisimo.com?gl5'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='私はガラスを食べられます',
                       filename='fullqry', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=17,
                      clustercount=0, perpage=2, num=2, filename='fullqry',
                      testname=tname)

   filename = yy.look_for_file(filename='fullqry')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 18"
   print tname, ":     numbers (1500)"

   explist = ['http://vivisimo.com?numbers',
              'http://vivisimo.com?numbers1500'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='千五百',
                       filename='1500', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=18,
                      clustercount=0, perpage=2, num=2, filename='1500',
                      testname=tname)

   filename = yy.look_for_file(filename='1500')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 19"
   print tname, ":     numbers (2)"

   explist = ['http://vivisimo.com?numbers']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='二',
                       filename='two', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=19,
                      clustercount=0, perpage=1, num=1, filename='two',
                      testname=tname)

   filename = yy.look_for_file(filename='two')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 20"
   print tname, ":     numbers (100)"

   explist = ['http://vivisimo.com?numbers']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='百',
                       filename='hundred', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=20,
                      clustercount=0, perpage=1, num=1, filename='hundred',
                      testname=tname)

   filename = yy.look_for_file(filename='hundred')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 21"
   print tname, ":     numbers (100)"

   cfile = 'case21'
   explist = ['http://vivisimo.com?gl7',
              'http://vivisimo.com?gl6']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='せん。Glass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=21,
                      clustercount=0, perpage=2, num=2, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 22"
   print tname, ":     numbers (100)"

   cfile = 'case22'
   explist = ['http://vivisimo.com?gl7',
              'http://vivisimo.com?gl6']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='せん。ＧＬＡＳＳ',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=22,
                      clustercount=0, perpage=2, num=2, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 23"
   print tname, ":     numbers (100)"

   cfile = 'case23'
   explist = ['http://vivisimo.com?gl7',
              'http://vivisimo.com?gl6']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ＧＬＡＳＳ',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=23,
                      clustercount=0, perpage=2, num=2, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 24"
   print tname, ":     numbers (100)"

   cfile = 'case24'
   explist = ['http://vivisimo.com?gl7',
              'http://vivisimo.com?gl6']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='glass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=24,
                      clustercount=0, perpage=2, num=2, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 25"
   print tname, ":     numbers (100)"

   cfile = 'case25'
   explist = ['http://vivisimo.com?gl7',
              'http://vivisimo.com?gl6']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='glass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=25,
                      clustercount=0, perpage=2, num=2, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   xx.kill_all_services()

   if ( cs_pass == 50 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
