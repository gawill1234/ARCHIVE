#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="exchange-1"
   DESCRIPTION="Basic exchange crawl and search"
   TARGETHOST=192.168.0.53

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#  Default version to 6.0 or greater
#
if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#basic_query_test 1 $SHOST $VCOLLECTION Vivisimo
#
simple_search -H $SHOST -C $VCOLLECTION -Q "Vivisimo" -T $VCOLLECTION -n 285
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

basic_query_test 2 $SHOST $VCOLLECTION Smurf
basic_query_test 3 $SHOST $VCOLLECTION December+17+2003
basic_query_test 4 $SHOST $VCOLLECTION jerome+pesenti
basic_query_test 5 $SHOST $VCOLLECTION test+downloaded

source $TEST_ROOT/lib/run_std_results.sh
