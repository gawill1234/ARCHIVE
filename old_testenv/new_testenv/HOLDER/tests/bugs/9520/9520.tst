#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="9520"
   DESCRIPTION="Japanese query bug test"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#   url encoded query
#
basic_query_test 1 $SHOST $VCOLLECTION "%E6%B1%82%E4%BA%BA%E6%83%85%E5%A0%B1+or+%22%E3%81%B8%E8%B2%B7%E5%8F%8E%E6%8F%90%E6%A1%88+1%E6%9C%88%22"

#
#   Basic utf8 type query
#
basic_query_test 2 $SHOST $VCOLLECTION "求人情報"
#basic_query_test 3 $SHOST $VCOLLECTION "へ買収提案 1月"
basic_query_test 3 $SHOST $VCOLLECTION "求人情報 or \"へ買収提案 1月\""

#diff_match_counts Hamilton

#diff_titles Hamilton

source $TEST_ROOT/lib/run_std_results.sh
