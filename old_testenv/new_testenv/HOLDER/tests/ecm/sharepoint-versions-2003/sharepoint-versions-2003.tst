#!/bin/bash

#####################################################################
#
#   Sharepoint 2003 basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="sharepoint-versions-2003"
   DESCRIPTION="Sharepoint2003 crawl of all versions of all documents"
   TARGETHOST=192.168.0.27

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

majorversion=`getmajorversion`

if [ $majorversion -lt 6 ]; then
   echo "Test Passed because it is not set to run in version less than 6"
   exit 0
fi

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION ""

source $TEST_ROOT/lib/run_std_results.sh
