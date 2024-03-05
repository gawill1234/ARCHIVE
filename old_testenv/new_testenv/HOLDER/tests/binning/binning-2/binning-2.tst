#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="binning-2"
   DESCRIPTION="simple oracle crawl and search with nested binning sets"

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

#basic_binning_test 3 $SHOST $VCOLLECTION ""
simple_binning -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`

full_bin_test 4 $SHOST $VCOLLECTION ship:Battleship
full_bin_test 5 $SHOST $VCOLLECTION ship:Cruiser
full_bin_test 6 $SHOST $VCOLLECTION ship:Battlecruiser:nations:USA
full_bin_test 7 $SHOST $VCOLLECTION ship:Frigate:nations:UK

source $TEST_ROOT/lib/run_std_results.sh
