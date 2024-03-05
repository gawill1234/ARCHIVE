#!/bin/bash

#####################################################################
#
#   Enterprise Vault basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="kvs-75"
   DESCRIPTION="Basic kvs crawl"
   TARGETHOST=192.168.0.67

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
basic_query_test 1 $SHOST $VCOLLECTION prevosti
basic_query_test 2 $SHOST $VCOLLECTION fatal
basic_query_test 3 $SHOST $VCOLLECTION regards
basic_query_test 4 $SHOST $VCOLLECTION release

source $TEST_ROOT/lib/run_std_results.sh
