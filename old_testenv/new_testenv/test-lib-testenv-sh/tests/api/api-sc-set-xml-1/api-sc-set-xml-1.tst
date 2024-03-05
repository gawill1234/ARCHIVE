#!/usr/bin/python

import sys, time, cgi_interface, vapi_interface 
import test_helpers, os

if __name__ == "__main__":

   collection_name = "ascstxml-1"
   collection_name_st = "ascstxml-1#staging"
   tname = 'api-sc-set-xml-1'
   colfile = ''.join([collection_name, '.xml'])
   basefile = ''.join([colfile, '.base'])
   #colfileupd = ''.join([collection_name, '-upd.xml'])
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

   thelper = test_helpers.TEST_HELPERS(yy, xx, None, tname)
   thelper.set_linux_samba_collection_access_data(basefile, colfile)

   cex = xx.collection_exists(collection=collection_name)

   if ( cex == 1 ):
      xx.delete_collection(collection=collection_name)

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

   print tname, ":  Configure the collection (xml)"
   #yy.api_repository_update(xx=xx, xmlfile=colfile)
   yy.api_sc_set_xml(xx=xx, urlfile=colfile, collection=collection_name)
   yy.api_sc_xml(xx=xx, collection=collection_name)

   print tname, ":  Run the crawl"
   thebeginning = time.time()
   xx.start_crawl(collection=collection_name)
   xx.wait_for_idle(collection=collection_name)

   print tname, ":  Query the collection"
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

   xx.kill_all_services()

   if ( cs_pass == 3 ):
      print tname, ":  Test Passed"
      xx.stop_crawl(collection=collection_name, force=1)
      xx.stop_indexing(collection=collection_name, force=1)
      xx.delete_collection(collection=collection_name)
      os.remove(colfile)
      sys.exit(0)

   print tname, ":  Test Failed"
   sys.exit(1)
