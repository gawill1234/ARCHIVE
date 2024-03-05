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

   collection_name = "wildcard-8"
   tname = 'wildcard-8'

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

   yy.api_repository_update(xx=xx, xmlfile="wc_options")

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
   print tname, ":  Wildcard search using fullwidth numbers"

   print tname, ":  #######################################"
   print tname, ":  CASE 1"
   print tname, ":     3*"

   cfile = 'usnum'

   explist = ['http://vivisimo.com?chevy',
              'http://vivisimo.com?mopar',
              'http://vivisimo.com?halfmopar',
              'http://vivisimo.com?halfchevy',
              'http://vivisimo.com?halfford',
              'http://vivisimo.com?ford']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='3*cid',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1,
                      clustercount=0, perpage=6, num=6, filename=cfile,
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
   print tname, ":  CASE 2"
   print tname, ":     ２６０*"

   cfile = 'underbore-full'

   explist = ['http://vivisimo.com?alpine',
              'http://vivisimo.com?halfaccobra',
              'http://vivisimo.com?halfalpine',
              'http://vivisimo.com?accobraspace',
              'http://vivisimo.com?accobra']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='２６０*',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2,
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
   print tname, ":  CASE 3"
   print tname, ":     260*"

   cfile = 'underbore-half'

   explist = ['http://vivisimo.com?alpine',
              'http://vivisimo.com?halfaccobra',
              'http://vivisimo.com?halfalpine',
              'http://vivisimo.com?accobra']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='260*',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                      clustercount=0, perpage=4, num=4, filename=cfile,
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

   print tname, ":  CASE 4"
   print tname, ":     4*5*"

   cfile = 'ascii-455'

   explist = ['http://vivisimo.com?chevy',
              'http://vivisimo.com?halfchevy']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='4*5*',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
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

   print tname, ":  CASE 5"
   print tname, ":     ４*５*"

   cfile = 'half-455'

   explist = ['http://vivisimo.com?chevy',
              'http://vivisimo.com?halfchevy']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='４*５*',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
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

   print tname, ":  CASE 6"
   print tname, ":     ４＊５＊"

   cfile = 'full-455'

   explist = ['http://vivisimo.com?chevy',
              'http://vivisimo.com?halfchevy']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='４*５*',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
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
   print tname, ":  CASE 7"
   print tname, ":     <empty query>"

   cfile = 'alleng'

   explist = ['http://vivisimo.com?chevy',
              'http://vivisimo.com?mopar',
              'http://vivisimo.com?foreign',
              'http://vivisimo.com?alpine',
              'http://vivisimo.com?accobra',
              'http://vivisimo.com?ford',
              'http://vivisimo.com?halfchevy',
              'http://vivisimo.com?halfmopar',
              'http://vivisimo.com?halfforeign',
              'http://vivisimo.com?halfalpine',
              'http://vivisimo.com?halfaccobra',
              'http://vivisimo.com?accobraspace',
              'http://vivisimo.com?accobraback',
              'http://vivisimo.com?halfford']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='',
                       filename=cfile, odup='true', num=14)
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=7,
                      clustercount=0, perpage=14, num=14, filename=cfile,
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

   print tname, ":  CASE 8"
   print tname, ":     260C*"

   cfile = 'underbore-again'

   explist = ['http://vivisimo.com?alpine',
              'http://vivisimo.com?halfaccobra',
              'http://vivisimo.com?halfalpine',
              'http://vivisimo.com?accobra']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='260C*',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=8,
                      clustercount=0, perpage=4, num=4, filename=cfile,
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
   print tname, ":  CASE 9"
   print tname, ":     ２６０"

   cfile = 'one-of-six'

   explist = ['http://vivisimo.com?accobraspace']

   yy.api_qsearch(xx=xx, source=collection_name,
                       query='２６０',
                       filename=cfile, odup='true')
   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=9,
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
   xx.repo_delete(elemtype="options", elemname="query-meta")

   xx.kill_all_services()

   if ( cs_pass == 18 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
