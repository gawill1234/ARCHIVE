#!/bin/bash

#####################################################################
#
#   Basic Sharepoint 2003 crawl and search, on alternate port
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="sharepoint-portal"
   DESCRIPTION="Basic Sharepoint 2003 Portal crawl"
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
basic_query_test 1 $SHOST $VCOLLECTION portaldoc
basic_query_test 2 $SHOST $VCOLLECTION teamsite2
basic_query_test 3 $SHOST $VCOLLECTION event
# Gary needs to check this one
#basic_query_test 4 $SHOST $VCOLLECTION CONTENT+title+CONTAINING+teamsite2

source $TEST_ROOT/lib/run_std_results.sh
