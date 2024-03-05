#!/bin/bash

#####################################################################
#
#   Sharepoint 2003 basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="eroom-7"
   DESCRIPTION="Basic eRoom 7 crawl"
   TARGETHOST=192.168.0.64

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check_nv $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION expense
basic_query_test 2 $SHOST $VCOLLECTION best+practice
basic_query_test 3 $SHOST $VCOLLECTION SBO
basic_query_test 4 $SHOST $VCOLLECTION documentum

source $TEST_ROOT/lib/run_std_results.sh
