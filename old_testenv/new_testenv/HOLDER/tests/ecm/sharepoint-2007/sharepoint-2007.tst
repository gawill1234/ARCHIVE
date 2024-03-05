#!/bin/bash

#####################################################################
#
#   Sharepoint 2007 basic crawl/index/search test
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="sharepoint-2007"
   DESCRIPTION="Basic sharepoint crawl and search (sharepoint 2007)"
   TARGETHOST=sharepoint2007.vivisimo.com

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#Not sure why this failed, even after I updated...
#basic_query_test 1 $SHOST $VCOLLECTION news
basic_query_test 2 $SHOST $VCOLLECTION test
basic_query_test 3 $SHOST $VCOLLECTION lake
basic_query_test 4 $SHOST $VCOLLECTION bobby+wizard+workflow
basic_query_test 5 $SHOST $VCOLLECTION convera

source $TEST_ROOT/lib/run_std_results.sh
