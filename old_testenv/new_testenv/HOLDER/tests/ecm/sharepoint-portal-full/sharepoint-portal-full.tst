#!/bin/bash

#####################################################################
#
#   Basic Sharepoint 2003 crawl and search, on alternate port
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="sharepoint-portal-full"
   DESCRIPTION="Basic Sharepoint 2003 crawl and search, on alternate port"
   TARGETHOST=192.168.0.27

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
basic_query_test 1 $SHOST $VCOLLECTION gougou
basic_query_test 2 $SHOST $VCOLLECTION url:z
basic_query_test 3 $SHOST $VCOLLECTION url:y
basic_query_test 4 $SHOST $VCOLLECTION contacts

source $TEST_ROOT/lib/run_std_results.sh