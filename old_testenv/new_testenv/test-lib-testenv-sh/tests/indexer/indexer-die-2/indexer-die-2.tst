#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="indexer-die-2"
   DESCRIPTION="oracle simple view crawl, kill indexer between queries"
   TARGETHOST=${VIV_ORACLE_DATABASE_SERVER}

###
###

export VIVERRIGN='COLLECTION_SERVICE_SERVICE_TERMINATED'
export VIVSYSERRIGN='indexer'

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

wait_for_indexer_death()
{

   counter=0
   ixid=`get_indexer_pid -C indexer-die-2`
   while [ "$ixid" != "" ]; do
      sleep 1
      ixid=`get_indexer_pid -C indexer-die-2`
      counter=`expr $counter + 1`
      if [ $counter -ge 10 ]; then
         break
      fi
   done

   if [ "$ixid" != "" ]; then
      echo "indexer did not die, $ixid"
   fi
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

idxid=`get_indexer_pid -C indexer-die-2`
#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Arizona
basic_query_test 2 $SHOST $VCOLLECTION Arizona+Battleship
basic_query_test 3 $SHOST $VCOLLECTION bismarck
basic_query_test 4 $SHOST $VCOLLECTION arizona
basic_query_test 5 $SHOST $VCOLLECTION Blücher

basres=$results


kill_service_children -C $VCOLLECTION -S indexer
wait_for_indexer_death
basic_query_test 6 $SHOST $VCOLLECTION Arizona

kill_service_children -C $VCOLLECTION -S indexer
wait_for_indexer_death
basic_query_test 7 $SHOST $VCOLLECTION Arizona+Battleship

kill_service_children -C $VCOLLECTION -S indexer
wait_for_indexer_death
basic_query_test 8 $SHOST $VCOLLECTION bismarck

kill_service_children -C $VCOLLECTION -S indexer
wait_for_indexer_death
basic_query_test 9 $SHOST $VCOLLECTION arizona

kill_service_children -C $VCOLLECTION -S indexer
wait_for_indexer_death
basic_query_test 10 $SHOST $VCOLLECTION Blücher

idxid2=`get_indexer_pid -C indexer-die-2`

if [ "$idxid" == "$idxid2" ] ||
   [ "$idxid" == "" ] ||
   [ "$idxid2" == "" ]; then
   echo "Indexer not killed as it should have been."
   echo "Indexer pid:  $idxid"
   results=`expr $results + 1`
   casecount=`expr $casecount + 1`
else
   casecount=`expr $casecount + 1`
   echo "Initial indexer pid:  $idxid"
   echo "Final indexer pid:    $idxid2"
fi

if [ $basres -eq 0 ]; then
   if [ $results -ne 0 ]; then
      echo "Indexer/query-service are not starting as rapidly as hoped."
      echo "This causes queries to return prematurely."
      echo "We know this because the base set of queries with no indexer"
      echo "death pass."
   fi
fi

source $TEST_ROOT/lib/run_std_results.sh
