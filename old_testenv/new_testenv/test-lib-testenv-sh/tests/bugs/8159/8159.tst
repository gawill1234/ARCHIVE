#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="8159"
   DESCRIPTION="various forms of <crawl-delete>"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

cnt=0
mymax=10

stime=`date +%s`
export VIVSTARTTIME=$stime

while [ $cnt -lt $mymax ]; do
   delete_collection -C $VCOLLECTION
   create_collection -C $VCOLLECTION
   start_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION
   sleep 5
   basic_query_test 1 $SHOST $VCOLLECTION "+"
   refresh_crawl -C $VCOLLECTION -W live
   wait_for_idle -C $VCOLLECTION
   sleep 5
   basic_query_test 2 $SHOST $VCOLLECTION "++"
   if [ $results -gt 0 ]; then
      cnt=100
   else
      cnt=`expr $cnt + 1`
   fi
done

source $TEST_ROOT/lib/run_std_results.sh
