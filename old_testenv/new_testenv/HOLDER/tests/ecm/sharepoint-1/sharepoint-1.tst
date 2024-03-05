#!/bin/bash

#####################################################################
#
#   Sharepoint 2003 basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="sharepoint-1"
   DESCRIPTION="Basic sharepoint crawl and search (sharepoint 2003)"
   TARGETHOST=testbed3-2.test.vivisimo.com

###
###

export VIVDEFCONVERT="true"

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
basic_query_test 1 $SHOST $VCOLLECTION Hamilton
basic_query_test 2 $SHOST $VCOLLECTION We+the+people
basic_query_test 3 $SHOST $VCOLLECTION iroquois
basic_query_test 4 $SHOST $VCOLLECTION jay
basic_query_test 5 $SHOST $VCOLLECTION Orion

source $TEST_ROOT/lib/run_std_results.sh
