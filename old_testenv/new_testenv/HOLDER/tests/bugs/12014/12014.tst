#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="12014"
   DESCRIPTION="crawl and search of various word2 docs"

###
###

export VIVDEFCONVERT="true"

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
basic_query_test 1 $SHOST $VCOLLECTION Hiking
#hasty
basic_query_test 2 $SHOST $VCOLLECTION "risk+averse"
#dye
basic_query_test 3 $SHOST $VCOLLECTION "cease+fire"
#all
basic_query_test 4 $SHOST $VCOLLECTION ""

source $TEST_ROOT/lib/run_std_results.sh
