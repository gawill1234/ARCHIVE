#!/usr/bin/python
import sys, os, random, time
import collectionObj, queryObj, docCmpObj, queryDataObj
import vapi_interface, cgi_interface

if __name__ == "__main__":

   allres = 0

   thingy = queryDataObj.queryData('queries')

   # Add custom repository node for ranged searches
   # Word-order-factor = 1 test
   vapi = vapi_interface.VAPIINTERFACE()
   xx = cgi_interface.CGIINTERFACE()
   xx.version_check(minversion=8.0)

   cex = xx.collection_exists(collection='qs-samba')
   if ( cex == 0 ):
      vapi.api_sc_create(collection='qs-samba')
   vapi.api_sc_set_xml(collection='qs-samba', urlfile='qs-samba.xml')
#   vapi.api_repository_update(xmlfile='qs-samba.xml')
   vapi.api_sc_update_config(collection='qs-samba')
   vapi.api_sc_crawler_stop(collection='qs-samba')
   vapi.api_sc_crawler_start(collection='qs-samba')
   vapi.api_sc_indexer_stop(collection='qs-samba')
   vapi.api_sc_indexer_start(collection='qs-samba')

   tc = None
   while ( thingy.get_current_query() is not None ):

      print "======================================================"

      thingy.dump_current_query()

      newc = thingy.get_current_query_collection()
      tq = thingy.get_current_query()
      too = thingy.get_current_otheropts()
      to = thingy.get_current_query_file()

      if ( newc != tc ):
         tc = newc
		 # Create search collection, reuse if it doesn't already exist
         thiscollection = collectionObj.Collection(collection_name=tc)

      #
      #   Reqular query-search
      #
      thisquery = queryObj.Query(collection_name=tc, query=tq, outfile=to,
                        otheroptions=too)

      thisquery.run_the_query()

      qout = thisquery.get_query_file()
      qcmp = thisquery.get_compare_file()

      resobj = docCmpObj.Compare(qout, qcmp)

      resobj.vb_score_compare()
      resobj.do_query_compare()
      resobj.do_binning_check()
      cpf = resobj.get_score_compare_result()

      print "---> COLLECTION : ", tc
      print "---> QUERY      : ", tq
      if ( cpf == 0 ):
         print "---> CASE RESULT:  Pass"
      else:
         print "---> CASE RESULT:  Fail"

      print "======================================================"

      allres += cpf

      thingy.next_query()

   thingy = queryDataObj.queryData('queries2')

   # Add custom repository node for ranged searches
   # Word-order-factor = 2 test
   vapi.api_sc_set_xml(collection='qs-samba', urlfile='qs-samba2.xml')
#   vapi.api_repository_update(xmlfile='qs-samba2.xml')
   vapi.api_sc_update_config(collection='qs-samba')
   vapi.api_sc_indexer_stop(collection='qs-samba')
   vapi.api_sc_indexer_start(collection='qs-samba')

   tc = None
   while ( thingy.get_current_query() is not None ):

      print "======================================================"

      thingy.dump_current_query()

      newc = thingy.get_current_query_collection()
      tq = thingy.get_current_query()
      too = thingy.get_current_otheropts()
      to = thingy.get_current_query_file()

      if ( newc != tc ):
         tc = newc
		 # Create search collection, reuse if it doesn't already exist
         thiscollection = collectionObj.Collection(collection_name=tc)

      #
      #   Reqular query-search
      #
      thisquery = queryObj.Query(collection_name=tc, query=tq, outfile=to,
                        otheroptions=too)

      thisquery.run_the_query()

      qout = thisquery.get_query_file()
      qcmp = thisquery.get_compare_file()

      resobj = docCmpObj.Compare(qout, qcmp)

      resobj.vb_score_compare()
      resobj.do_query_compare()
      resobj.do_binning_check()
      cpf = resobj.get_score_compare_result()

      print "---> COLLECTION : ", tc
      print "---> QUERY      : ", tq
      if ( cpf == 0 ):
         print "---> CASE RESULT:  Pass"
      else:
         print "---> CASE RESULT:  Fail"

      print "======================================================"

      allres += cpf

      thingy.next_query()

   thingy = queryDataObj.queryData('queries3')

   # Add custom repository node for ranged searches
   # Word order factor = 3 test
   vapi.api_sc_set_xml(collection='qs-samba', urlfile='qs-samba3.xml')
#   vapi.api_repository_update(xmlfile='qs-samba3.xml')
   vapi.api_sc_update_config(collection='qs-samba')
   vapi.api_sc_indexer_stop(collection='qs-samba')
   vapi.api_sc_indexer_start(collection='qs-samba')

   tc = None
   while ( thingy.get_current_query() is not None ):

      print "======================================================"

      thingy.dump_current_query()

      newc = thingy.get_current_query_collection()
      tq = thingy.get_current_query()
      too = thingy.get_current_otheropts()
      to = thingy.get_current_query_file()

      if ( newc != tc ):
         tc = newc
		 # Create search collection, reuse if it doesn't already exist
         thiscollection = collectionObj.Collection(collection_name=tc)

      #
      #   Reqular query-search
      #
      thisquery = queryObj.Query(collection_name=tc, query=tq, outfile=to,
                        otheroptions=too)

      thisquery.run_the_query()

      qout = thisquery.get_query_file()
      qcmp = thisquery.get_compare_file()

      resobj = docCmpObj.Compare(qout, qcmp)

      resobj.vb_score_compare()
      resobj.do_query_compare()
      resobj.do_binning_check()
      cpf = resobj.get_score_compare_result()

      print "---> COLLECTION : ", tc
      print "---> QUERY      : ", tq
      if ( cpf == 0 ):
         print "---> CASE RESULT:  Pass"
      else:
         print "---> CASE RESULT:  Fail"

      print "======================================================"

      allres += cpf

      thingy.next_query()


   vapi.api_sc_set_xml(collection='qs-samba', urlfile='qs-samba.xml')
#   vapi.api_repository_update(xmlfile='qs-samba3.xml')
   vapi.api_sc_update_config(collection='qs-samba')
   vapi.api_sc_indexer_stop(collection='qs-samba')
   vapi.api_sc_indexer_start(collection='qs-samba')

   if ( allres == 0 ):
      print "mytest:  Test Passed"
   else:
      print "mytest:  Test Failed"

   sys.exit(allres)
