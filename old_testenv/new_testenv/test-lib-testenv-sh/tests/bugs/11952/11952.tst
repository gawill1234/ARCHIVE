#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="11952"
   DESCRIPTION="crawl and search of doc which causes out of memory in convert"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
sz=`get_index_size -C $VCOLLECTION`
if [ $sz -gt 0 ]; then
   basic_query_test 1 $SHOST $VCOLLECTION Index
   basic_query_test 4 $SHOST $VCOLLECTION ""
fi

source $TEST_ROOT/lib/run_std_results.sh
