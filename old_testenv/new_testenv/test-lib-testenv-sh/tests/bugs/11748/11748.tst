#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="11748"
   DESCRIPTION="crawl and search of various doc types for various bugs"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#abrams
basic_query_test 1 $SHOST $VCOLLECTION Virginia
#hasty
basic_query_test 2 $SHOST $VCOLLECTION "Legion+Insurance"
#dye
basic_query_test 3 $SHOST $VCOLLECTION WorkSite
#all
basic_query_test 4 $SHOST $VCOLLECTION ""

source $TEST_ROOT/lib/run_std_results.sh
