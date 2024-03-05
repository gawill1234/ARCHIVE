#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="postgres-3"
   DESCRIPTION="postgres database and table do not exist"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
sz=`get_index_size -C $VCOLLECTION`
if [ $sz -gt 0 ]; then
   basic_query_test 1 $SHOST $VCOLLECTION Arizona
   basic_query_test 2 $SHOST $VCOLLECTION Arizona+Battleship
   basic_query_test 3 $SHOST $VCOLLECTION bismarck
   basic_query_test 4 $SHOST $VCOLLECTION arizona
   basic_query_test 5 $SHOST $VCOLLECTION Blücher
fi

source $TEST_ROOT/lib/run_std_results.sh
