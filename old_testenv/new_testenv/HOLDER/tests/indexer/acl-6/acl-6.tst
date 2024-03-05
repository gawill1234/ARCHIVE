#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="acl-6"
   DESCRIPTION="test overlapping acls"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

simple_search -H $SHOST -C $VCOLLECTION -Q "+" -T $VCOLLECTION -r "pos1%0apos2"
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
   testpass=0
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

simple_search -H $SHOST -C $VCOLLECTION -Q "++" -T $VCOLLECTION -r "pos1%0apos2%0aneg1"
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
   testpass=0
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

source $TEST_ROOT/lib/run_std_results.sh

