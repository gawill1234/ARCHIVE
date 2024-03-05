#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="metadata-2"
   DESCRIPTION="simple oracle crawl and search with meta-data/fast-indexing on multiple fields"

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
basic_query_test 1 $SHOST $VCOLLECTION "SHIP_TYPE:Battleship"
basic_query_test 2 $SHOST $VCOLLECTION "NATION:Germany"
basic_query_test 3 $SHOST $VCOLLECTION "ALIGNED:allies"

source $TEST_ROOT/lib/run_std_results.sh
