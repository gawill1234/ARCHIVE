#!/bin/bash

#####################################################################

###
#   Global stuff
###
#
#   This test does a no-follow crawl of 4 url's.
#   The URLs should be enqueued and a crawl attempted, 
#   but nothing will be indexed.
#
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="no-follow-1"
   DESCRIPTION="Crawl of enqueued bogus URLs with no-follow set"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#  Default version to 6.0 or greater
#
if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
