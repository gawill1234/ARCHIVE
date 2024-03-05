#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="12269"
   DESCRIPTION="crawl a smb directory with over 250k documents"

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
basic_query_test 1 $SHOST $VCOLLECTION "a"
basic_query_test 2 $SHOST $VCOLLECTION "ａ"
basic_query_test 3 $SHOST $VCOLLECTION "rex"
basic_query_test 4 $SHOST $VCOLLECTION "Ｒｅｘ　Ｂｌａｃｋ"
basic_query_test 5 $SHOST $VCOLLECTION "소프트웨어"
basic_query_test 6 $SHOST $VCOLLECTION "소프트"
basic_query_test 7 $SHOST $VCOLLECTION "ambitions"
basic_query_test 8 $SHOST $VCOLLECTION "雄心勃勃的"
basic_query_test 9 $SHOST $VCOLLECTION "雄勃勃的"
basic_query_test 10 $SHOST $VCOLLECTION "雄"
basic_query_test 11 $SHOST $VCOLLECTION "ipone300"

source $TEST_ROOT/lib/run_std_results.sh

