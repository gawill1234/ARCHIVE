#!/bin/bash

#####################################################################
#
#   Sharepoint 2003 basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="kvs"
   DESCRIPTION="Basic kvs crawl"
   TARGETHOST=192.168.0.27

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
basic_query_test 1 $SHOST $VCOLLECTION journal
basic_query_test 2 $SHOST $VCOLLECTION vivisimo
basic_query_test 3 $SHOST $VCOLLECTION troubling+assault
basic_query_test 4 $SHOST $VCOLLECTION version+control

source $TEST_ROOT/lib/run_std_results.sh
