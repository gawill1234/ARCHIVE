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

   collection_name = "asceq-1"
   tname = 'api-sc-enqueue-1'

   crlurlnd = '<crawl-url url="http://testbed4.test.vivisimo.com/" enqueue-type="forced"><curl-options><curl-option name="default-allow" added="added">allow</curl-option><curl-option name="max-hops" added="added">1</curl-option></curl-options></crawl-url>'

   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  search-collection-enqueue-url"
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
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1, clustercount=0,
                      perpage=43, num=43, filename='base_urls',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=1, clustercount=0,
                      perpage=46, num=46, filename='base_urls',
                      testname=tname)

   print tname, ":  ##################"
   print tname, ":  The actual enqueue"
   print tname, ":  enqueue url (http://testbed4.test.vivisimo.com)"
   yy.api_sc_enqueue(xx=xx, collection=collection_name,
                      url=crlurlnd)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  query updated collection and check data"
   print tname, ":     includes enqueue urls"
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='all_urls')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                      perpage=57, num=57, filename='all_urls',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=2, clustercount=0,
                      perpage=60, num=60, filename='all_urls',
                      testname=tname)


   print tname, ":  ##################"
   print tname, ":  Get rid of the enqueued data"
   print tname, ":  refresh the crawl"
   xx.refresh_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  query the updated collection and make sure"
   print tname, ":     data reflects deletion of enqueued urls"
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='refresh_urls')

   if ( yy.TENV.targetos == "solaris" ):
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                      perpage=43, num=43, filename='refresh_urls',
                      testname=tname)
   else:
      cs_pass = cs_pass + yy.query_result_check(xx=xx,casenum=3, clustercount=0,
                      perpage=46, num=46, filename='refresh_urls',
                      testname=tname)
   ##############################################################

   xx.kill_all_services()

   if ( cs_pass == 3 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
