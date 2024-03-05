#!/usr/bin/python

import sys, os, random, time
import collectionObj, queryObj, docCmpObj, queryDataObj

if __name__ == "__main__":

   allres = 0

   thingy = queryDataObj.queryData('queries')

   #print thingy.get_full_term_list()

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
         thiscollection = collectionObj.Collection(collection_name=tc)
         #thiscollection = collectionObj.Collection(collection_name=tc,
         #                                          build_collection='rebuild')

      #
      #   Reqular query-search
      #
      thisquery = queryObj.Query(collection_name=tc, query=tq, outfile=to,
                        otheroptions=too)
      #
      #   Reqular collection-broker-search
      #
      #thisquery = queryObj.Query(collection_name=tc, query=tq, outfile=to,
      #                  otheroptions=too, use_cb=True)

      thisquery.run_the_query()

      qout = thisquery.get_query_file()
      qcmp = thisquery.get_compare_file()

      resobj = docCmpObj.Compare(qout, qcmp)

      cpf = resobj.do_full_compare()

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
