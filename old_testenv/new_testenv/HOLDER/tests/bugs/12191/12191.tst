#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="12191"
   DESCRIPTION="crawl a single file of one huge 100M string"

###
###

MAXTIME=120

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/bg_setup.sh
crawl_check $SHOST $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh

