#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6456"
   DESCRIPTION="test failed + successful converter memory limit"

###
###

export VIVRUNTARGET="windows"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

delete_collection -C $VCOLLECTION
create_collection -C $VCOLLECTION

start_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

basic_query_test 1 $SHOST $VCOLLECTION +

refresh_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

basic_query_test 2 $SHOST $VCOLLECTION ++

source $TEST_ROOT/lib/run_std_results.sh
