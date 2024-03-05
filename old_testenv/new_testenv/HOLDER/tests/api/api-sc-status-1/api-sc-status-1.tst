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

   collection_name = "ascstat-1"
   tname = 'api-sc-status-1'
   colfile = ''.join([collection_name, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  search-collection-status"
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
   print tname, ":  Get the collection status"
   yy.api_sc_status(xx=xx, collection=collection_name)

   print tname, ":  Check a bit of the collection status data(indexed urls)"
   iurls = yy.get_vse_status_data(xx=xx, vfunc='search-collection-status',
                                  trib='index-urls')

   if ( int(iurls) == 52 ):
      cs_pass = cs_pass + 1
      print tname, ":  Correct number of indexed urls"
   else:
      print tname, ":  Wrong number of indexed urls"

   print tname, ":     Expected, 52"
   print tname, ":     Actual,  ", iurls

   print tname, ":  ##################"
   print tname, ":  Get the collection xml"
   yy.api_sc_xml(xx=xx, collection=collection_name)

   print tname, ":  Check the nodes in the collection xml"
   cs_pass = cs_pass + yy.check_collection_xml_node_count(xx=xx,
                                    collection=collection_name,
                                    vfunc='search-collection-xml')

   ##############################################################

   if ( cs_pass == 3 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
