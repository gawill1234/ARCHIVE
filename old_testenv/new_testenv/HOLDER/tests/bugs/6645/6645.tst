#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6645"
   DESCRIPTION="textfile with embedded nuls"

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
basic_query_test 1 $SHOST $VCOLLECTION 9802
basic_query_test 2 $SHOST $VCOLLECTION 00000181525
basic_query_test 3 $SHOST $VCOLLECTION 264453

source $TEST_ROOT/lib/run_std_results.sh
