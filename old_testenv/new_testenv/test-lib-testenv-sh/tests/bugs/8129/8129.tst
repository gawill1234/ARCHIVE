#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="8129"
   DESCRIPTION="test default-acl set as global crawler option"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

delete_collection -C $VCOLLECTION
create_collection -C $VCOLLECTION

stime=`date +%s`
export VIVSTARTTIME=$stime

start_crawl -C $VCOLLECTION -W live
wait_for_idle -C $VCOLLECTION

casecount=`expr $casecount + 3`

simple_search -H $SHOST -C $VCOLLECTION -Q "+" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1 (without rights): Case Failed"
else
   echo "test 1 (without rights): Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "++" -T $VCOLLECTION -n 2150 -r "everyone"
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2 (with rights): Case Failed"
else
   echo "test 2 (with rights): Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "+++" -T $VCOLLECTION -n 2150 -r "-everyone"
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3 (with bad rights): Case Failed"
else
   echo "test 3 (with bad rights): Case Passed"
fi
results=`expr $results + $xx`

source $TEST_ROOT/lib/run_std_results.sh
