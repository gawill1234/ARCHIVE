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

   VCOLLECTION="crawler-stop"
   DESCRIPTION="Crawl and query collection while stopping/resuming crawler"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="crawler indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

MAXITER=10

#
#  source $TEST_ROOT/lib/run_std_setup.sh
#
getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW

create_collection -C $VCOLLECTION -H $SHOST
stime=`date +%s`
export VIVSTARTTIME=$stime
start_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

sleep 2
echo "GET STATUS OF CRAWL"
get_status -C $VCOLLECTION
x=$?

count=1
while [ $x -eq 3 ]; do
   echo "Iteration:  $count"
   echo "Current status value:  $x"
   sleepval=`genrand -M 90 -m 5`
   echo "Kill crawler and then wait $sleepval seconds"
   stop_crawler -C $VCOLLECTION
   sleep 1
   resume_crawl -C $VCOLLECTION
   sleep $sleepval
   get_status -C $VCOLLECTION
   x=$?
   if [ $count -ge $MAXITER ]; then
      break
   fi
   count=`expr $count + 1`
done

#
#   Now, wait for all of the remaining indexer stuff
#
wait_for_idle -C $VCOLLECTION

crawl_check_nv $SHOST $VCOLLECTION

#
#   Do a refresh if there was a collection based timeout
#   But put the results back to what it was so the test will
#   still fail based on initial results.  However, we will also
#   get the info that A)  there were timeouts and B) a refresh
#   caused the crawl to complete differently than the original
#   messed up crawl.
#
if [ $results -ne 0 ]; then
   x=`do_action -C $VCOLLECTION -A count -F junkfile`
   if [ $x -ne 2149 ]; then
      echo "$VCOLLECTION:  Found $x results, expected 2149"
      echo "$VCOLLECTION:  Getting the collection log database"
      do_action -C $VCOLLECTION -A db -D log
      echo "$VCOLLECTION:  Looking for connector timeout errors"
      y=`do_action -C $VCOLLECTION -A dbquery -Q "select xml from errors;" -F log.sqlt | grep -i timeout | wc -l`
      if [ $y -ge 1 ]; then
         #
         #   Save old results
         #
         holdresult=$results
         results=0
         echo "$VCOLLECTION:  Timeouts found, doing a crawl refresh"
         refresh_crawl -C $VCOLLECTION
         wait_for_idle -C $VCOLLECTION
         crawl_check_nv $SHOST $VCOLLECTION
         if [ $results -ne $holdresults ]; then
            echo "$VCOLLECTION:  Doing a refresh changed the collection data"
         fi
         #
         #   Restore old results
         #
         results=$holdresults
      fi
   fi
fi

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
