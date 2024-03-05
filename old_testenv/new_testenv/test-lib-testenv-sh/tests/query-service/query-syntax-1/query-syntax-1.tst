#!/bin/bash

#####################################################################

###
#   Global stuff
###
#
#   Query syntax test of basic "and" or "or"
#
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="query-syntax-1"
   DESCRIPTION="query syntax check and and or"

###
###

export VIVLOWVERSION=6.1

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
basic_query_test 1 $SHOST $VCOLLECTION "Arizona%20and%20Battleship"
basic_query_test 2 $SHOST $VCOLLECTION "German%20and%20Battleship"
basic_query_test 3 $SHOST $VCOLLECTION "German%20or%20Battleship"
basic_query_test 4 $SHOST $VCOLLECTION "%28German%20or%20Battleship%29%20or%20pocket"
basic_query_test 5 $SHOST $VCOLLECTION "%28German%20or%20Pocket%29"
basic_query_test 6 $SHOST $VCOLLECTION "%28North%20and%20Carolina%29%20or%20%28Battleship%20and%20Arizona%29"
basic_query_test 7 $SHOST $VCOLLECTION "%28%28North%20and%20Carolina%29%20within%20content%20title%29%20or%20%28Battleship%20and%20Arizona%29"
#
#  (title:(North and Carolina)) or (Arizona and battleship)
#
basic_query_test 8 $SHOST $VCOLLECTION "%28title%3A%28North%20and%20Carolina%29%29%20or%20%28Arizona%20and%20Battleship%29"
#
#  (title:(North and Carolina))or(Arizona and battleship)
#
basic_query_test 9 $SHOST $VCOLLECTION "%28title%3A%28North%20and%20Carolina%29%29or%28Arizona%20and%20Battleship%29"
#
#  (title:(North+and+Carolina))+or+(Arizona+and+battleship)
#
basic_query_test 10 $SHOST $VCOLLECTION "%28title%3A%28North+and+Carolina%29%29+or+%28Arizona+and+Battleship%29"
#
#  \\ battleship
#
basic_query_test 11 $SHOST $VCOLLECTION "%5C%5C%20battleship"
#

source $TEST_ROOT/lib/run_std_results.sh
