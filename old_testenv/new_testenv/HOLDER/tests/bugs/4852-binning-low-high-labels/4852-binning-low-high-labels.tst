#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="4852-binning-low-high-labels"
   DESCRIPTION="test new number-label-xpath functionality of binning"

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

check_bin_attribute -C $VCOLLECTION -A label
check_bin_attribute -C $VCOLLECTION -A label-low
check_bin_attribute -C $VCOLLECTION -A label-high
check_bin_attribute -C $VCOLLECTION -A low
check_bin_attribute -C $VCOLLECTION -A high

source $TEST_ROOT/lib/run_std_results.sh
