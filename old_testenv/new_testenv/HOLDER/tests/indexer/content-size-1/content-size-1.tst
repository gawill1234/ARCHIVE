#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="content-size-1"
   DESCRIPTION="Default content size with edge queries"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

sleep 2
testpass=0

#
#   function basic_query_test
#   args are test number, host, collection, query string

#
#   The first query should pass
#
basic_query_test 1 $SHOST $VCOLLECTION 3890279083885318125329708
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 1:  Did not get result when should have"
   testpass=0
fi

#
#   The second query should fail but should match
#
basic_query_test 2 $SHOST $VCOLLECTION 5409971775950845020239800
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 2:  Got result when should not have"
   testpass=0
fi

#
#   The third query should pass
#
basic_query_test 3 $SHOST $VCOLLECTION 1245750260153694554008555
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 3:  Did not get result when should have"
   testpass=0
fi

if [ $testpass -eq 1 ]; then
   echo "TEST RESULT FOR $VCOLLECTION:  Test Passed"
   delete_collection -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
   exit 0
fi

echo "TEST RESULT FOR $VCOLLECTION:  Test Failed"
exit 1

