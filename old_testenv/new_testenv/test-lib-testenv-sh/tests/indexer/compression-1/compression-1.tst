#!/bin/bash

#####################################################################

###
#   Global stuff
###
#
#   This test is a copy of oracle-1, but with compression enabled.
#   Other than compression, this test is identical and should
#   therefore have identical results.
#

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="compression-1"
   DESCRIPTION="oracle simple view crawl and search with compression"
   TARGETHOST=${VIV_ORACLE_DATABASE_SERVER}

###
###

export VIVLOWVERSION=6.1

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
basic_query_test 2 $SHOST $VCOLLECTION Arizona+Battleship
basic_query_test 3 $SHOST $VCOLLECTION bismarck
basic_query_test 4 $SHOST $VCOLLECTION arizona
basic_query_test 5 $SHOST $VCOLLECTION Blücher

diff_match_counts Arizona
diff_match_counts Arizona+Battleship
diff_match_counts bismarck
diff_match_counts arizona
diff_match_counts Blücher

source $TEST_ROOT/lib/run_std_results.sh
