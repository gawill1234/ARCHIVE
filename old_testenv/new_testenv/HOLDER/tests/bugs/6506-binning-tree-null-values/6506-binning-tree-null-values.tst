#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6506-binning-tree-null-values"
   DESCRIPTION="bug 6506"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

start_crawl -C $VCOLLECTION

wait_for_idle -C $VCOLLECTION

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#

indexing_test_status -C $VCOLLECTION
err=$?

if [ $err -ne 0 ]; then
   results=`expr $results + 1`
fi

source $TEST_ROOT/lib/run_std_results.sh

