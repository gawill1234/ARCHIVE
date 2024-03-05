#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="5554"
   DESCRIPTION="test precision of binning range output with very high and very low values"

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

if ! check_bin_attribute -C $VCOLLECTION -A label ; then results=`expr $results + 1` ; fi
if ! check_bin_attribute -C $VCOLLECTION -A label-low ; then results=`expr $results + 1` ; fi
if ! check_bin_attribute -C $VCOLLECTION -A label-high ; then results=`expr $results + 1` ; fi
if ! check_bin_attribute -C $VCOLLECTION -A low ; then results=`expr $results + 1` ; fi
if ! check_bin_attribute -C $VCOLLECTION -A high ; then results=`expr $results + 1` ; fi

source $TEST_ROOT/lib/run_std_results.sh
