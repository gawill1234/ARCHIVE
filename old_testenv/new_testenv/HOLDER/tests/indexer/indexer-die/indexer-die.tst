#!/bin/bash

#####################################################################

###
#   Global stuff
#
#   This test creates a collection and starts a crawl.
#   After the crawl is started, it periodically kills the
#   indexer.  The indexer should recover and complete
#   normally.  It kills the indexer 100 times, then
#   waits for the remainder of the crawl to finish.  After
#   the crawl completes a number if queries are issued which
#   should return the known correct results
#
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="indexer-die"
   DESCRIPTION="Crawl and query collection while killing indexer"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

MAXITER=100
hangon=0

majorversion=`getmajorversion`

if [ "$majorversion" -lt "6" ]; then
   echo "Test not valid for version older than 6.0"
   exit 0
fi

#
#  source $TEST_ROOT/lib/run_std_setup.sh
#
getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW

create_collection -C $VCOLLECTION -H $SHOST
stime=`date +%s`
export VIVSTARTTIME=$stime
start_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

#
#  Sometimes we get in too quick and things are still idle.
#  This kludge fixes it.
#
sleep 5
get_status -C $VCOLLECTION
x=$?

count=1
while [ $x -eq 3 ]; do
   echo "Iteration:  $count"
   echo "Current status value:  $x"
   sleepval=`genrand -M 90 -m 1`
   echo "Kill indexer and then wait $sleepval seconds"
   kill_service_children -C $VCOLLECTION -S indexer
   sleep $sleepval
   get_status -C $VCOLLECTION
   x=$?
   zz=`hang_check -C $VCOLLECTION`
   if [ $zz -gt 0 ]; then
      hangon=`expr $hangon + 1`
   else
      hangon=0
   fi
   if [ $hangon -gt 3 ]; then
      echo "$VCOLLECTION:  Crawler/Indexer hung"
      echo "$VCOLLECTION:  Test Failed"
      exit 1
   fi
   if [ $count -ge $MAXITER ]; then
      break
   fi
   count=`expr $count + 1`
done

echo "Final status value:  $x"
#
#   It expects no queries, and by doing a query it forces
#   the indexer to restart (right?)
#
simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150

#
#   Now, wait for all of the remaining indexer stuff
#
wait_for_idle -C $VCOLLECTION
wfistat=$?
if [ $wfistat -eq 2 ]; then
   echo "$VCOLLECTION:  Crawler/Indexer hung"
   echo "$VCOLLECTION:  Test Failed"
   exit 1
fi


crawl_check_nv $SHOST $VCOLLECTION

casecount=`expr $casecount + 6`

#
#   Kill the indexer and issue queries; repeatedly.
#   Each query should magically cause the indexer/query part
#   to restart.
#
kill_service_children -C $VCOLLECTION -S indexer

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
kill_service_children -C $VCOLLECTION -S indexer

simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton+Madison" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION -S indexer

simple_search -H $SHOST -C $VCOLLECTION -Q "Linux" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION -S indexer

simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION -S indexer

simple_search -H $SHOST -C $VCOLLECTION -Q "We+the+people" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION -S indexer

simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
results=`expr $results + $xx`

source $TEST_ROOT/lib/run_std_results.sh
