#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="music-2"
   DESCRIPTION="samba crawl and search of .wav files"

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

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 1000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`

basic_query_test 2 $SHOST $VCOLLECTION "kabal"
basic_query_test 3 $SHOST $VCOLLECTION "CopyAudio"

source $TEST_ROOT/lib/run_std_results.sh
