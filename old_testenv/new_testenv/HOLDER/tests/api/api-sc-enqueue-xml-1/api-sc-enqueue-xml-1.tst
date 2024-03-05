#!/usr/bin/python

#
#   Test of the api
#   This test is for search-collection-create and
#   search-collection-delete.  It creates and deletes
#   a number of collections using different variations
#   of characters.
#

import sys, time, cgi_interface, vapi_interface 


if __name__ == "__main__":

   collection_name = "asceqx-1"
   tname = 'api-sc-enqueue-xml-1'
   enqueue_url = '<crawl-url url="http://testbed4.test.vivisimo.com/" enqueue-type="forced"><curl-options><curl-option name="default-allow" added="added">allow</curl-option><curl-option name="max-hops" added="added">1</curl-option></curl-options></crawl-url>'
   del_url = '<crawl-delete url="http://testbed4.test.vivisimo.com/" />'
   del_url2 = '<crawl-delete url="http://testbed4.test.vivisimo.com/pages/hate_products.htm" />'
   del_url3 = '<crawl-delete url="http://testbed4.test.vivisimo.com/pages/like_products.htm" />'
   del_url4 = '<crawl-urls><crawl-delete url="http://testbed4.test.vivisimo.com/pages/would_again.htm" /><crawl-delete url="http://testbed4.test.vivisimo.com/docs/Current_Resume.htm" /></crawl-urls>'
   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  search-collection-enqueue-xml"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.0)

   print tname, ":  Create and check the base collection"
   xx.create_collection(collection=collection_name, usedefcon=1)

   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='base_urls')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                      perpage=43, num=43, filename='base_urls',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                      perpage=46, num=46, filename='base_urls',
                      testname=tname)

   print tname, ":  ##################"
   print tname, ":  The actual enqueue"
   print tname, ":  enqueue url (http://testbed4.test.vivisimo.com)"
   yy.api_sc_enqueue_xml(xx=xx, collection=collection_name,
                         url=enqueue_url)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  query updated collection and check data"
   print tname, ":     includes enqueue urls"
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='all_urls')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                      perpage=57, num=57, filename='all_urls',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=2, clustercount=0,
                      perpage=60, num=60, filename='all_urls',
                      testname=tname)


   print tname, ":  ##################"
   print tname, ":  Get rid of the enqueued data"
   print tname, ":  refresh the crawl"
   yy.api_sc_enqueue_xml(xx=xx, collection=collection_name, url=del_url)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  query the updated collection and make sure"
   print tname, ":     data reflects deletion of enqueued urls"
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='del_urls')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                      perpage=56, num=56, filename='del_urls',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=3, clustercount=0,
                      perpage=59, num=59, filename='del_urls',
                      testname=tname)

   print tname, ":  ##################"
   print tname, ":  Get rid of the two pieces of enqueued data"
   print tname, ":  refresh the crawl"
   yy.api_sc_enqueue_xml(xx=xx, collection=collection_name, url=del_url2)
   yy.api_sc_enqueue_xml(xx=xx, collection=collection_name, url=del_url3)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  query the updated collection and make sure"
   print tname, ":     data reflects deletion of enqueued urls"
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='del_urls2')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                      perpage=54, num=54, filename='del_urls2',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=4, clustercount=0,
                      perpage=57, num=57, filename='del_urls2',
                      testname=tname)

   print tname, ":  ##################"
   print tname, ":  Get rid of the two pieces of enqueued data at once"
   print tname, ":  refresh the crawl"
   yy.api_sc_enqueue_xml(xx=xx, collection=collection_name, url=del_url4)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  query the updated collection and make sure"
   print tname, ":     data reflects deletion of enqueued urls"
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='del_urls4')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                      perpage=52, num=52, filename='del_urls4',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=5, clustercount=0,
                      perpage=55, num=55, filename='del_urls4',
                      testname=tname)
   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == 5 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
