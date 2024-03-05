#!/usr/bin/python
# -*- coding: utf-8 -*-

#
#   Test for bug 20997.  Checks that a string after
#   a character which would have caused the string to
#   become garbled/destroyed does not by querying for that
#   string.
#
#   The data is in /testenv/samba_test_data/20997/test.xls
#

import sys, time, cgi_interface, vapi_interface 

if __name__ == "__main__":

   cs_pass = 0

   collection_name = "25533"
   tname = "25533"
   colfile = ''.join([collection_name, '.xml'])

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
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
   print tname, ":  CASE 1, visible rights with check-set"
   qobj = '<operator logic="equal"> \
             <term field="c-set" str="c-set-1"/> \
           </operator>'

   explist = ['http://1/']

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='rights1', rights='visible')

   cs_pass = cs_pass + yy.query_result_check(xx=xx,
                                       casenum=1, clustercount=0,
                                       perpage=1, num=1, filename='rights1')

   filename = yy.look_for_file(filename='rights1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 2, invisible rights with check-set"
   qobj = '<operator logic="equal"> \
             <term field="c-set" str="c-set-2"/> \
           </operator>'

   explist = []

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='rights2', rights='visible')

   cs_pass = cs_pass + yy.query_result_check(xx=xx,
                                       casenum=2, clustercount=0,
                                       perpage=0, num=0, filename='rights2')

   filename = yy.look_for_file(filename='rights2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 3, no rights with check-set"

   qobj = '<operator logic="equal"> \
             <term field="c-set" str="c-set-2"/> \
           </operator>'
   explist = ['http://1/']

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='rights3')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3,
                                       clustercount=0,
                                       perpage=1, num=1, filename='rights3')

   filename = yy.look_for_file(filename='rights3')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"

   print tname, ":  ##################"
   print tname, ":  CASE 4, rights with check-date"

   qobj = '<operator logic="equal"> \
             <term field="c-date" str="December 21, 2012"/> \
           </operator>'
   explist = ['http://2/']

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='date1', rights='visible')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4,
                                       clustercount=0,
                                       perpage=1, num=1, filename='date1')

   filename = yy.look_for_file(filename='date1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 5, rights with check-date"

   qobj = '<operator logic="equal"> \
             <term field="c-date" str="12/21/2012"/> \
           </operator>'
   explist = ['http://2/']

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='date2', rights='visible')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5,
                                       clustercount=0,
                                       perpage=1, num=1, filename='date2')

   filename = yy.look_for_file(filename='date2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 6, rights with check-int"

   qobj = '<operator logic="equal"> \
             <term field="c-int" str="2012"/> \
           </operator>'
   explist = ['http://3/']

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='int1', rights='visible')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                                       clustercount=0,
                                       perpage=1, num=1, filename='int1')

   filename = yy.look_for_file(filename='int1')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"
   print tname, ":  ##################"
   print tname, ":  CASE 7, rights with check-int"

   qobj = '<operator logic="equal"> \
             <term field="c-int" str="2010"/> \
           </operator>'
   explist = []

   yy.api_qsearch(xx=xx, vfunc='query-search', source='25533',
                  qobj=qobj, filename='int2', rights='visible')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=6,
                                       clustercount=0,
                                       perpage=0, num=0, filename='int2')

   filename = yy.look_for_file(filename='int2')
   urllist = xx.get_sorted_query_urls(filenm=filename, retlist=1)

   ret = yy.check_list(explist, urllist)
   if ( ret == 0 ):
      print tname, ":     Expected URLs match"
      cs_pass = cs_pass + 1
   else:
      print tname, ":     Expected URLs do not match"

   print tname, ":  ##################"

   print tname, ":  cs_pass =", cs_pass

   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == 14 ):
      xx.delete_collection(collection=collection_name)
      print tname, ":  Test Passed"
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
