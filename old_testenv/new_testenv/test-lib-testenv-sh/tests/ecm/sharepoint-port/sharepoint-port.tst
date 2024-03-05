#!/bin/bash

#####################################################################
#
#   Basic Sharepoint 2003 crawl and search, on alternate port
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="sharepoint-port"
   DESCRIPTION="Basic Sharepoint 2003 crawl and search, on alternate port"
   TARGETHOST=192.168.0.27

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION events
#basic_query_test 2 $SHOST $VCOLLECTION We+the+people
#basic_query_test 3 $SHOST $VCOLLECTION iroquois
#basic_query_test 4 $SHOST $VCOLLECTION jay
#basic_query_test 5 $SHOST $VCOLLECTION Orion

source $TEST_ROOT/lib/run_std_results.sh
