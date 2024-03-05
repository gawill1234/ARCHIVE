#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="binning-ranges"
   DESCRIPTION="simple oracle crawl and search with meta-data and binning"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#basic_query_test 1 $SHOST $VCOLLECTION ""

simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 400
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`

source $TEST_ROOT/lib/run_std_results.sh
