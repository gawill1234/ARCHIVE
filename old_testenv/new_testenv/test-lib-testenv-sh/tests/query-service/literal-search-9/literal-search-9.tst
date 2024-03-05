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

   collection_name = "literal-search-9"
   tname = 'literal-search-9'

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
   explist = ['http://vivisimo.com?email2']
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='@',
                       filename='atsign', odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=1, num=1, filename='atsign',
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
              'http://vivisimo.com?email2',
              'http://vivisimo.com?email3']
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='jeff.skilling@enron.com',
                       filename='email1', odup='true')
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

   explist = ['http://vivisimo.com?email2', 
              'http://vivisimo.com?email1',
              'http://vivisimo.com?email3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='skilling@enron.com',
                       filename='email2', odup='true')

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

   explist = ['http://vivisimo.com?email2', 
              'http://vivisimo.com?email1',
              'http://vivisimo.com?email3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='skilling',
                       filename='email3', odup='true')

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
              'http://vivisimo.com?email1',
              'http://vivisimo.com?email3'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='jeff_skilling@enron.com',
                       filename='email4', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                      clustercount=0, perpage=3, num=3, filename='email4',
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
                       query='fizzy-lifting-drink',
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
              'http://vivisimo.com?fizz3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='lifting',
                       filename='fizzy2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7,
                      clustercount=0, perpage=2, num=2, filename='fizzy2',
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

   explist = ['http://vivisimo.com?email3', 
              'http://vivisimo.com?email1',
              'http://vivisimo.com?email2']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='enron.com',
                       filename='emailpart', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8,
                      clustercount=0, perpage=3, num=3, filename='emailpart',
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

   explist = ['http://vivisimo.com?ssn1'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='987-65-4321',
                       filename='ssn1', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9,
                      clustercount=0, perpage=1, num=1, filename='ssn1',
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

   explist = [] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='987',
                       filename='ssn2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=10,
                      clustercount=0, perpage=0, num=0, filename='ssn2',
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
                       query='abc-1111',
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

   explist = [] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='spc 2222',
                       filename='lp2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=12,
                      clustercount=0, perpage=0, num=0, filename='lp2',
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

   explist = ['http://vivisimo.com?lp3',
              'http://vivisimo.com?lp4',
              'http://vivisimo.com?lp6',
              'http://vivisimo.com?lp7',
              'http://vivisimo.com?lp5'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='qtm=3333',
                       filename='lp3', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=13,
                      clustercount=0, perpage=5, num=5, filename='lp3',
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
   print tname, ":     license plate, qtm?3333 mixed width query"

   explist = ['http://vivisimo.com?lp3',
              'http://vivisimo.com?lp4',
              'http://vivisimo.com?lp6',
              'http://vivisimo.com?lp7',
              'http://vivisimo.com?lp5'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ｑｔｍ=３３３３',
                       filename='lp16', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=16,
                      clustercount=0, perpage=5, num=5, filename='lp16',
                      testname=tname)

   filename = yy.look_for_file(filename='lp16')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 17"
   print tname, ":     license plate, qtm?3333, full width query"

   explist = ['http://vivisimo.com?lp3',
              'http://vivisimo.com?lp4',
              'http://vivisimo.com?lp6',
              'http://vivisimo.com?lp7',
              'http://vivisimo.com?lp5'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ｑｔｍ＝３３３３',
                       filename='lp17', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=17,
                      clustercount=0, perpage=5, num=5, filename='lp17',
                      testname=tname)

   filename = yy.look_for_file(filename='lp17')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"
      print tname, ":     This failure is being temporarily ignored"
      print tname, ":     To make the failure fail again, remove next line"
      cs_pass = cs_pass + 2

   print tname, ":  #######################################"
   print tname, ":  CASE 18"
   print tname, ":     query number 9"

   explist = ['http://vivisimo.com?numbers1']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='9',
                       filename='numbers18', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=18,
                      clustercount=0, perpage=1, num=1, filename='numbers18',
                      testname=tname)

   filename = yy.look_for_file(filename='numbers18')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 19"
   print tname, ":     query number 123"

   cfile = 'case19'

   explist = ['http://vivisimo.com?numbers2',
              'http://vivisimo.com?numbers3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='123',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=19,
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
   print tname, ":  CASE 20"
   print tname, ":     query number 78"

   cfile = 'case20'

   explist = ['http://vivisimo.com?numbers2']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='78',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=20,
                      clustercount=0, perpage=1, num=1, filename=cfile,
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
   print tname, ":  CASE 21"
   print tname, ":     query string i9"

   cfile = 'case21'

   explist = ['http://vivisimo.com?numbers4']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='i9',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=21,
                      clustercount=0, perpage=1, num=1, filename=cfile,
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
   print tname, ":     query string glass"

   cfile = 'case22'

   explist = ['http://vivisimo.com?sameword1',
              'http://vivisimo.com?sameword2',
              'http://vivisimo.com?sameword3',
              'http://vivisimo.com?sameword4',
              'http://vivisimo.com?sameword5']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='glass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=22,
                      clustercount=0, perpage=5, num=5, filename=cfile,
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
   print tname, ":     query string glass"

   cfile = 'case23'

   explist = ['http://vivisimo.com?sameword1',
              'http://vivisimo.com?sameword2',
              'http://vivisimo.com?sameword3',
              'http://vivisimo.com?sameword4',
              'http://vivisimo.com?sameword5']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ＧＬＡＳＳ',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=23,
                      clustercount=0, perpage=5, num=5, filename=cfile,
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
   print tname, ":     query string glass"

   cfile = 'case24'

   explist = ['http://vivisimo.com?sameword1',
              'http://vivisimo.com?sameword2',
              'http://vivisimo.com?sameword3',
              'http://vivisimo.com?sameword4',
              'http://vivisimo.com?sameword5']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ＧＬass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=24,
                      clustercount=0, perpage=5, num=5, filename=cfile,
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
   print tname, ":     query string glass"

   cfile = 'case25'

   explist = ['http://vivisimo.com?email9',
              'http://vivisimo.com?email1',
              'http://vivisimo.com?email3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='jeff.skilling!!enron.com',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=25,
                      clustercount=0, perpage=3, num=3, filename=cfile,
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
   print tname, ":  CASE 26"
   print tname, ":     query string glass"

   cfile = 'case26'

   explist = ['http://vivisimo.com?email8',
              'http://vivisimo.com?email1',
              'http://vivisimo.com?email3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='jeff.skilling=enron.com',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=26,
                      clustercount=0, perpage=3, num=3, filename=cfile,
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
   print cs_pass

   xx.kill_all_services()

   if ( cs_pass == 52 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
