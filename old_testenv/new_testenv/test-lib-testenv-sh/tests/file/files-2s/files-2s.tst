#!/bin/bash

#####################################################################

###
#   Global stuff
###

#
#   This tests is a crawl only test.  It crawl a large data set
#   and checks the results of the crawl numbers.  This test does
#   not delete the target collection as it is a prerequisite to
#   other search tests.  This is done because this crawl takes an
#   extended period of time and we would rather not repeat the crawl
#   unless it is required.
#
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="files-2s"
   DESCRIPTION="samba crawl(only) of many(700K) html docs"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#   Check for the existence of the file system on the target
#

majorversion=`getmajorversion`

if [ "$majorversion" -lt "6" ]; then
   echo "Test not valid for version older than 6.0"
   exit 0
fi

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   Delete the collection only if the test fails.  This will force 
#   dependent tests to rerun this test in an attempt to get proper
#   results
#
export VIVDELETE="none"

source $TEST_ROOT/lib/run_std_results.sh
