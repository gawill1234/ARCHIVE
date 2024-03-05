#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="mysql-2"
   DESCRIPTION="mysql multi-table crawl and search with xsl view simulation"

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
basic_query_test 1 $SHOST $VCOLLECTION Arizona
basic_query_test 2 $SHOST $VCOLLECTION bismarck
basic_query_test 3 $SHOST $VCOLLECTION arizona
basic_query_test 4 $SHOST $VCOLLECTION Blücher

source $TEST_ROOT/lib/run_std_results.sh
