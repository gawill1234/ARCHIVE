#!/bin/bash

#####################################################################

###
#   Global stuff
#
#   This test creates two search collection and starts a crawl.
#   After the crawl is started, it periodically kills the
#   client collection. The crawler should recover and complete
#   normally.  It kills the crawler times, then
#   waits for the remainder of the crawl to finish.  After
#   the crawl completes a number if queries are issued which
#   should return the known correct results
#
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VTESTNAME="mirror-test-2"
   VCOLLECTION_SERVER="mirror-test-2-server"
   VCOLLECTION_CLIENT="mirror-test-2-client"
   DESCRIPTION="Crawl and query a distributed collection while killing/resuming the client crawler"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VTESTNAME $DESCRIPTION

MAXITER=20

majorversion=`getmajorversion`

if [ "$majorversion" -lt "7" ]; then
   echo "Test not valid for version older than 7.0"
   exit 0
fi

#
#  source $TEST_ROOT/lib/run_std_setup.sh
#
getsetopts $*
cleanup $SHOST $VCOLLECTION_SERVER $VUSER $VPW
cleanup $SHOST $VCOLLECTION_CLIENT $VUSER $VPW

create_collection -C $VCOLLECTION_SERVER -H $SHOST
create_collection -C $VCOLLECTION_CLIENT -H $SHOST
start_crawl -C $VCOLLECTION_SERVER -H $SHOST -U $VUSER -P $VPW
start_crawl -C $VCOLLECTION_CLIENT -H $SHOST -U $VUSER -P $VPW

sleep 2
get_status -C $VCOLLECTION_SERVER
x=$?

count=1
while [ $x -eq 3 ]; do
   echo "Iteration:  $count"
   echo "Current status value:  $x"
   sleepval=`genrand -M 120 -m 60`
   echo "Kill client crawler and then wait $sleepval seconds"
   y=`get_crawler_pid -C $VCOLLECTION_CLIENT`
   if [ "$y" != "" ]; then
      kill_service_children -C $VCOLLECTION_CLIENT -S supplied -p $y
      sleep 1
      resume_crawl -C $VCOLLECTION_CLIENT
      sleep $sleepval
   fi
   get_status -C $VCOLLECTION_CLIENT
   x=$?
   if [ $count -ge $MAXITER ]; then
      break
   fi
   count=`expr $count + 1`
done

#
#   Now, wait for all of the remaining indexer stuff
#
wait_for_idle -C $VCOLLECTION_SERVER
wait_for_idle -C $VCOLLECTION_CLIENT

crawl_check_nv $SHOST $VCOLLECTION_SERVER
crawl_check_nv $SHOST $VCOLLECTION_CLIENT

casecount=`expr $casecount + 6`

#
#   args are test number, host, collection, query string
#

#
#   Test the clients's collection
#
simple_search -H $SHOST -C $VCOLLECTION_CLIENT -Q "Hamilton" -T $VCOLLECTION_CLIENT -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION_CLIENT -Q "Hamilton+Madison" -T $VCOLLECTION_CLIENT -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION_CLIENT -Q "Linux" -T $VCOLLECTION_CLIENT -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION_CLIENT -S indexer

simple_search -H $SHOST -C $VCOLLECTION_CLIENT -Q "Stinkybottom" -T $VCOLLECTION_CLIENT -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION_CLIENT -S indexer

simple_search -H $SHOST -C $VCOLLECTION_CLIENT -Q "We+the+people" -T $VCOLLECTION_CLIENT -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
results=`expr $results + $xx`
kill_service_children -C $VCOLLECTION_CLIENT -S indexer

simple_search -H $SHOST -C $VCOLLECTION_CLIENT -Q "" -T $VCOLLECTION_CLIENT -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
results=`expr $results + $xx`

source $TEST_ROOT/lib/run_std_results.sh
