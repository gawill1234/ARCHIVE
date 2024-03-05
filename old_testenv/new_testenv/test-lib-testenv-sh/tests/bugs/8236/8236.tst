#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="nested-binning-set-multiple-values"
   DESCRIPTION="bug 8236"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

basic_query_test 1 $SHOST $VCOLLECTION ""

basic_binning_test 2 $SHOST $VCOLLECTION ""

source $TEST_ROOT/lib/run_std_results.sh

