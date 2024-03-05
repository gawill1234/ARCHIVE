#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="content-size-5"
   DESCRIPTION="Default content size of with queries past the default"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTIO=live

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

testpass=0

#
#   function basic_query_test
#   args are test number, host, collection, query string

#
#   The first query should pass
#   Random number sequence in file
#
basic_query_test 1 $SHOST $VCOLLECTION "good+tidings+of+great+joy"
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 1:  Did not get result when should have"
   testpass=0
fi

#
#   The second query should pass
#   Last full number sequence in file
#
basic_query_test 2 $SHOST $VCOLLECTION 3890279083885318125329708
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 2:  Did not get result when should have"
   testpass=0
fi

#
#   The third query should pass
#   Absolute last number sequence in file
#
basic_query_test 3 $SHOST $VCOLLECTION "Brian+Gaines"
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 3:  Did not get result when should have"
   testpass=0
fi

#
#   The fourth query should pass
#   First number sequence in file
#
basic_query_test 4 $SHOST $VCOLLECTION "Adam+Eve"
if [ $results -eq 0 ]; then
   testpass=1
else
   echo "$VCOLLECTION, Case 4:  Did not get result when should have"
   testpass=0
fi

if [ $testpass -eq 1 ]; then
   echo "TEST RESULT FOR $VCOLLECTION:  Test Passed"
   delete_collection -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
   exit 0
fi

echo "TEST RESULT FOR $VCOLLECTION:  Test Failed"
exit 1

