#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="basic_web_crawl"
   DESCRIPTION="Crawl a web site with crawler defaults"

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

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Seven
basic_query_test 2 $SHOST $VCOLLECTION Audio
basic_query_test 3 $SHOST $VCOLLECTION Electronic+Supply
basic_query_test 4 $SHOST $VCOLLECTION midas

source $TEST_ROOT/lib/run_std_results.sh
