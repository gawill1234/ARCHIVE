#!/usr/bin/python
import sys, os, random, time
import collectionObj, queryObj, docCmpObj, queryDataObj
import vapi_interface

if __name__ == "__main__":

   allres = 0
   file = None
   version = float(os.environ["VIVVERSION"])
   if ( version >= 8.0 ):
        print "Using 8.0"
        file = '8.0queries'
   else:
        print "Found older than 8.0"
        file = 'queries'

   thingy = queryDataObj.queryData(file)

   # Add custom repository node for ranged searches
   vapi = vapi_interface.VAPIINTERFACE()
   vapi.api_repository_update(xmlfile='syntaxnode.xml')

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

   if ( allres == 0 ):
      print "mytest:  Test Passed"
   else:
      print "mytest:  Test Failed"


   sys.exit(allres)
