#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-2a"
   DESCRIPTION="samba crawl and search of various doc types"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION


if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`
source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

casecount=`expr $casecount + 6`

#
#   args are test number, host, collection, query string
#
simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton+Madison" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Linux" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "We+the+people" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
results=`expr $results + $xx`

source $TEST_ROOT/lib/run_std_results.sh
