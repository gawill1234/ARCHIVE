#!/bin/bash

#####################################################################
#
#   Sharepoint 2003 basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="aqualogic-1"
   DESCRIPTION="Basic aqualogic crawl"
   TARGETHOST=testbed2.test.vivisimo.com

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
basic_query_test 1 $SHOST $VCOLLECTION bye
basic_query_test 2 $SHOST $VCOLLECTION Heritrix
basic_query_test 3 $SHOST $VCOLLECTION prevosti
basic_query_test 4 $SHOST $VCOLLECTION item

source $TEST_ROOT/lib/run_std_results.sh
