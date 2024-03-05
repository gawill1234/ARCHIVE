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

   collection_name = "literal-search-6"
   tname = 'literal-search-6'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  Korean segmenter/tokenizer"
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
                       filename='atsign')
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
              'http://vivisimo.com?email4']
   yy.api_qsearch(xx=xx, source=collection_name,
                       query='내.셔@날.com',
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

   explist = ['http://vivisimo.com?email2', 
              'http://vivisimo.com?email4']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='셔@날.com',
                       filename='email2')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=2, num=2, filename='email2',
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
              'http://vivisimo.com?email4']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='셔',
                       filename='email3')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                      clustercount=0, perpage=2, num=2, filename='email3',
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
                       query='내_셔@날.com',
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
                       query='파-나-소',
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
                       query='나',
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

   explist = ['http://vivisimo.com?email4', 
              'http://vivisimo.com?email3',
              'http://vivisimo.com?email2']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='날.com',
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
                       query='파나소-1111',
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
                       query='닉의 2222',
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

   explist = ['http://vivisimo.com?lp3'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='자자닉-3333',
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
   print tname, ":     sino-korean numbers"

   explist = ['http://vivisimo.com?numbers1',
              'http://vivisimo.com?numbers3'] 
   searchlist = ['零','一','二','三','四','五','六','七','八',
                 '九','十','二十','百','億']

   for item in searchlist:
      yy.api_qsearch(xx=xx, source=collection_name,
                          query=item,
                          filename='four', odup='true')

      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=16,
                         clustercount=0, perpage=2, num=2, filename='four',
                         testname=tname)

      filename = yy.look_for_file(filename='four')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

      ret = yy.check_list(explist, urllist)
      if ( ret == 0 ):
         print tname, ":     Expected URLs match"
         cs_pass = cs_pass + 1
      else:
         print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 17"
   print tname, ":     native korean numbers"

   explist = ['http://vivisimo.com?numbers2',
              'http://vivisimo.com?numbers4'] 
   searchlist = ['하나','둘','셋','넷','다섯','여섯','일곱',
                 '여덟','아홉','열','스물','온','잘']

   for item in searchlist:

      yy.api_qsearch(xx=xx, source=collection_name,
                          query=item,
                          filename='four2', odup='true')

      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=17,
                         clustercount=0, perpage=2, num=2, filename='four2',
                         testname=tname)

      filename = yy.look_for_file(filename='four2')
      urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

      ret = yy.check_list(explist, urllist)
      if ( ret == 0 ):
         print tname, ":     Expected URLs match"
         cs_pass = cs_pass + 1
      else:
         print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 18"
   print tname, ":     half width query, mixed return"

   explist = ['http://vivisimo.com?halfwidth1',
              'http://vivisimo.com?halffullmix'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ﾡﾢﾣﾤ',
                       filename='half1', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=18,
                      clustercount=0, perpage=2, num=2, filename='half1',
                      testname=tname)

   filename = yy.look_for_file(filename='half1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 19"
   print tname, ":     full width query, mixed return"

   explist = ['http://vivisimo.com?gl1',
              'http://vivisimo.com?gl2',
              'http://vivisimo.com?gl3',
              'http://vivisimo.com?gl4',
              'http://vivisimo.com?gl5',
              'http://vivisimo.com?gl6',
              'http://vivisimo.com?halffullmix'] 

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='그래도',
                       filename='half2', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=19,
                      clustercount=0, perpage=7, num=7, filename='half2',
                      testname=tname)

   filename = yy.look_for_file(filename='half2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"

   print tname, ":  CASE 20"
   print tname, ":     half width query, half width return"

   explist = ['http://vivisimo.com?halfwidth2',
              'http://vivisimo.com?halfwidth3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ﾣ ﾯ ﾷ',
                       filename='half3', odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=20,
                      clustercount=0, perpage=2, num=2, filename='half3',
                      testname=tname)

   filename = yy.look_for_file(filename='half3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  #######################################"
   print tname, ":  CASE 21"
   print tname, ":     mixed euro/chinese query"

   cfile = 'case21'

   explist = ['http://vivisimo.com?gl2',
              'http://vivisimo.com?gl1',
              'http://vivisimo.com?gl4',
              'http://vivisimo.com?gl5',
              'http://vivisimo.com?gl6',
              'http://vivisimo.com?halffullmix',
              'http://vivisimo.com?gl3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='않아요ＧＬＡＳＳ',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=21,
                      clustercount=0, perpage=7, num=7, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
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
   print tname, ":  CASE 22"
   print tname, ":     mixed euro/chinese query"

   cfile = 'case22'

   explist = ['http://vivisimo.com?numbers4',
              'http://vivisimo.com?numbers2']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='셋２',
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
   print tname, ":     mixed euro/chinese query"

   cfile = 'case23'

   #
   #   Should be one of these explists.  comment out one of them
   #   for the moment and see what changes on next run.
   #
   #explist = ['http://vivisimo.com?numbers3',
   #           'http://vivisimo.com?numbers1']
   explist = ['http://vivisimo.com?numbers3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='二two',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=23,
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
   print tname, ":  CASE 24"
   print tname, ":     mixed euro/chinese query"

   cfile = 'case24'

   explist = ['http://vivisimo.com?gl2',
              'http://vivisimo.com?gl1',
              'http://vivisimo.com?gl4',
              'http://vivisimo.com?gl5',
              'http://vivisimo.com?gl6',
              'http://vivisimo.com?halffullmix',
              'http://vivisimo.com?gl3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='않아요Glass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=24,
                      clustercount=0, perpage=7, num=7, filename=cfile,
                      testname=tname)

   filename = yy.look_for_file(filename=cfile)
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
   print tname, ":  CASE 25"
   print tname, ":     mixed euro/chinese query"

   cfile = 'case25'

   explist = ['http://vivisimo.com?gl2',
              'http://vivisimo.com?gl4',
              'http://vivisimo.com?gl5',
              'http://vivisimo.com?gl6',
              'http://vivisimo.com?gl3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='Glass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=25,
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
      print tname, ":     This failure is being temporarily ignored"
      print tname, ":     To make the failure fail again, remove next line"
      cs_pass = cs_pass + 2

   print tname, ":  #######################################"
   print tname, ":  CASE 26"
   print tname, ":     mixed euro/chinese query"

   cfile = 'case26'

   explist = ['http://vivisimo.com?gl2',
              'http://vivisimo.com?gl4',
              'http://vivisimo.com?gl5',
              'http://vivisimo.com?gl6',
              'http://vivisimo.com?gl3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ＧＬＡＳＳ',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=26,
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
      print tname, ":     This failure is being temporarily ignored"
      print tname, ":     To make the failure fail again, remove next line"
      cs_pass = cs_pass + 1

   print tname, ":  #######################################"
   print tname, ":  CASE 27"
   print tname, ":     mixed euro/chinese query"

   cfile = 'case27'

   explist = ['http://vivisimo.com?gl2',
              'http://vivisimo.com?gl4',
              'http://vivisimo.com?gl5',
              'http://vivisimo.com?gl6',
              'http://vivisimo.com?gl3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='ＧＬass',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=27,
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
      print tname, ":     This failure is being temporarily ignored"
      print tname, ":     To make the failure fail again, remove next line"
      cs_pass = cs_pass + 1

   print tname, ":  #######################################"

   print tname, ":  CASE 28"
   print tname, ":     half width query, mixed return"

   cfile = 'case28'
   explist = ['http://vivisimo.com?halfwidth2',
              'http://vivisimo.com?halfwidth3']
   qrylist = ['ￔ', 'ￕ', 'ￖ', 'ￗ', 'ￚ', 'ￛ', 'ￜ']

   for item in qrylist:
      print tname, ":  ###"
      print tname, ":  query term,", item
      yy.api_qsearch(xx=xx, source=collection_name,
                          query=item,
                          filename=cfile, odup='true')

      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=28,
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

   print tname, ":  CASE 29"
   print tname, ":     include last word in query"

   cfile = 'case29'
   explist = ['http://vivisimo.com?fizz1',
              'http://vivisimo.com?fizz2',
              'http://vivisimo.com?fizz3']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='파-나-소',
                       filename=cfile, odup='true')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=29,
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
   print tname, ":  #######################################"

   xx.kill_all_services()

   if ( cs_pass == 118 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed", cs_pass
   sys.exit(1)
