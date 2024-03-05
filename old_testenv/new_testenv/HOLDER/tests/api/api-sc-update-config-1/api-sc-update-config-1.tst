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

   collection_name = "ascupcfg-1"
   collection_name_st = "ascupcfg-1#staging"
   othername = "oracle-1"
   tname = 'api-sc-update-config-1'
   colfile = ''.join([collection_name, '.xml'])
   colfile2 = ''.join([othername, '.xml'])
   maxcount = 10
   i = 0
   cs_pass = 0

   ##############################################################
   print tname, ":  ##################"
   print tname, ":  INITIALIZE"
   print tname, ":  search-collection-set-xml (test 1)"
   print tname, ":     Create a collection using api functions"
   print tname, ":     search-collection-create and"
   print tname, ":     search-collection-set-xml"
   xx = cgi_interface.CGIINTERFACE()
   yy = vapi_interface.VAPIINTERFACE()
   xx.version_check(7.0)
   mystype = 'new'

   cex = xx.collection_exists(collection=collection_name)

   if ( cex == 1 ):
      print tname, ":  Old collection exists.  Deleting."
      yy.api_sc_crawler_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_indexer_stop(xx=xx, collection=collection_name, killit='true')
      yy.api_sc_delete(xx=xx, collection=collection_name)
      cex = xx.collection_exists(collection=collection_name)
      if ( cex == 1 ):
         print tname, ":  Old collection still exists.  Trying something."
         mystype = 'refresh-inplace'
         

   print tname, ":  Create the collection"
   yy.api_sc_create(xx=xx, collection=collection_name)

   print tname, ":  ##################"
   print tname, ":  Get the collection status"
   cex = xx.collection_exists(collection=collection_name)

   if ( cex != 1 ):
      print tname, ":  Collection was not created.  Exiting"
      print tname, ":  Test Failed"
      sys.exit(1)
   else:
      print tname, ":  Collection was created.  Continuing ..."

   print tname, ":  Configure the collection (xml), using repository-update"
   yy.api_repository_update(xx=xx, xmlfile=colfile)

   print tname, ":  Update the collection (internal to velocity)"
   print tname, ":     This is the actual search collection config update"
   yy.api_sc_update_config(xx=xx, collection=collection_name)

   print tname, ":  Run the crawl"
   thebeginning = time.time()
   yy.api_sc_crawler_start(xx=xx, collection=collection_name,
                           stype=mystype)
   #xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  Query the collection"
   #yy.api_query_search(xx=xx, source=collection_name, query='',
   #  cluster='false', fetchtimeout=10000, num=10000, filename='base_urls')
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='base_urls')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                      perpage=46, num=46, filename='base_urls',
                      testname=tname)

   print tname, ":  ##################"
   print tname, ":  Get the collection status"
   yy.api_sc_status(xx=xx, collection=collection_name)

   print tname, ":  Check a bit of the collection status data(indexed urls)"
   iurls = yy.get_vse_status_data(xx=xx, vfunc='search-collection-status',
                                  trib='index-urls')

   if ( mystype == 'new' ):
      if ( int(iurls) == 52 ):
         cs_pass = cs_pass + 1
         print tname, ":  Correct number of indexed urls"
      else:
         print tname, ":  Wrong number of indexed urls"
   else:
      if ( int(iurls) >= 52 ):
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

   print tname, ":  Configure the collection (xml), using repository-update"
   yy.api_repository_update(xx=xx, xmlfile=colfile2)

   print tname, ":  Update the collection (internal to velocity)"
   print tname, ":     This is the actual search collection config update"
   yy.api_sc_update_config(xx=xx, collection=collection_name)

   print tname, ":  Run the crawl"
   thebeginning = time.time()
   yy.api_sc_crawler_start(xx=xx, collection=collection_name,
                           stype='refresh-inplace')
   #xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  Query the collection"
   #yy.api_query_search(xx=xx, source=collection_name, query='',
   #  cluster='false', fetchtimeout=10000, num=10000, filename='new_urls')
   yy.api_qsearch(xx=xx, source=collection_name, query='',
     cluster='false', fetchtimeout=10000, num=10000, filename='new_urls')

   cs_pass = cs_pass + yy.query_result_check(xx=xx, casenum=1, clustercount=0,
                      perpage=352, num=352, filename='new_urls',
                      testname=tname)

   print tname, ":  ##################"
   print tname, ":  Get the collection status"
   yy.api_sc_status(xx=xx, collection=collection_name)

   print tname, ":  Check a bit of the collection status data(indexed urls)"
   iurls = yy.get_vse_status_data(xx=xx, vfunc='search-collection-status',
                                  trib='index-urls')

   if ( mystype == 'new' ):
      if ( int(iurls) == 412 ):
         cs_pass = cs_pass + 1
         print tname, ":  Correct number of indexed urls"
      else:
         print tname, ":  Wrong number of indexed urls"
   else:
      if ( int(iurls) >= 412 ):
         cs_pass = cs_pass + 1
         print tname, ":  Correct number of indexed urls"
      else:
         print tname, ":  Wrong number of indexed urls"

   print tname, ":     Expected, 412"
   print tname, ":     Actual,  ", iurls

   print tname, ":  ##################"
   print tname, ":  Get the collection xml"
   yy.api_sc_xml(xx=xx, collection=collection_name)

   print tname, ":  Check the nodes in the collection xml"
   cs_pass = cs_pass + yy.check_collection_xml_node_count(xx=xx,
                                    collection=collection_name,
                                    vfunc='search-collection-xml')

   ##############################################################

   if ( cs_pass == 6 ):
      print tname, ":  Test Passed"
      yy.cleanup_collection(collection_name, delete=True)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
