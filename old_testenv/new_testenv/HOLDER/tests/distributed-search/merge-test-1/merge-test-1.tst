#!/bin/bash

#####################################################################

###
#   Global stuff
#
#   This test creates two distributed search collections that
#   share one anothers updates and crawl slightly different data
#
#   The test starts both collections' crawls and kills
#   the server collection repeatedly. It then waits
#   for both crawls to complete  
#
#   Afterwards  number if queries are issued to both collections 
#   which should return the known correct results
#
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VTESTNAME="merge-test-1"
   VCOLLECTION_SERVER="merge-test-1-pdf"
   VCOLLECTION_CLIENT="merge-test-1-xml"
   DESCRIPTION="Crawl and query merged distributed collections"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VTESTNAME $DESCRIPTION

MAXITER=10

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
   sleepval=`genrand -M 240 -m 120`
   echo "Kill pdf crawler and then wait $sleepval seconds"
   y=`get_crawler_pid -C $VCOLLECTION_SERVER`
   if [ "$y" != "" ]; then
      kill_service_children -C $VCOLLECTION_SERVER -S supplied -p $y
      sleep 1
      resume_crawl -C $VCOLLECTION_SERVER
      sleep $sleepval
   fi
   get_status -C $VCOLLECTION_SERVER
   x=$?
   if [ $count -ge $MAXITER ]; then
      break
   fi
   count=`expr $count + 1`
done
#
#   Now, wait for all of the remaining indexer stuff
#
wait_for_idle -C $VCOLLECTION_CLIENT
wait_for_idle -C $VCOLLECTION_SERVER

#
#   Wait again to make sure that they've both received
#   all the updates
#
wait_for_idle -C $VCOLLECTION_CLIENT
wait_for_idle -C $VCOLLECTION_SERVER

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
