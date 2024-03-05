#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-11"
   DESCRIPTION="Windows (64bit) samba crawl and search of various doc types"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

#
#   New version has different results than old.
#
if [ "$majorversion" -le "5" ]; then
   cp $VCOLLECTION.5-6.xml $VCOLLECTION.xml
else
   cp $VCOLLECTION.6-0.xml $VCOLLECTION.xml
fi

source $TEST_ROOT/lib/run_std_setup.sh

#
#   Commented out until the queries start to pass.
#   Simplifies maintaining these error tests.
#
#crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION We+the+people
basic_query_test 2 $SHOST $VCOLLECTION Search+and+seizure
basic_query_test 3 $SHOST $VCOLLECTION Great+Creator
basic_query_test 4 $SHOST $VCOLLECTION shumoku0606_35328.xls
basic_query_test 5 $SHOST $VCOLLECTION 06-331c_53528.pdf

source $TEST_ROOT/lib/run_std_results.sh
