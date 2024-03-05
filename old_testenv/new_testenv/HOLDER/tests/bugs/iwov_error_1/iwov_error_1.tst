#!/bin/bash

#####################################################################

#
#   If this test finishes on its own, it passes.  Otherwise it
#   fails.
#

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="iwov_error_1"
   DESCRIPTION="check malformed xml in crawler database does not damage indexer"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#   Wait for 60 iterations of 5 seconds each for a total
#   of 5 minutes.
#
MAXITER=60
waitperiod=5
casecount=1

majorversion=`getmajorversion`

#
#   In order to run on windows, this test must kill all other
#   indexer services so that it can check on its own.  In
#   other words, this test must run by itself on the target
#   box.
#
pidlist=`get_service_pid_list -S indexer`

for item in $pidlist; do
   kill_service_children -S supplied -p $item
done

#
#   Start the crawl
#
cleanup $SHOST $VCOLLECTION $VUSER $VPW

create_collection -C $VCOLLECTION
start_crawl -C $VCOLLECTION

sleep $waitperiod
get_status -C $VCOLLECTION
x=$?

count=0

while [ $x -ne 0 ]; do
   if [ $x -eq 3 ]; then
      echo "Crawler still running ..."
   elif [ $x -eq 2 ]; then
      echo "Indexer still running ..."
   else
      echo "Checking status ... ($x)"
   fi
   sleep $waitperiod
   count=`expr $count + 1`
   if [ $count -gt $MAXITER ]; then
      echo "Waited for indexer for 5 minutes.  It did not finish."
      echo "Check that it is not hung."
      kill_all_services
      kill_all_services
      results=`expr $results + 1`
      break
   fi
   get_status -C $VCOLLECTION
   x=$?
done

if [ $x -eq 0 ]; then
   echo "Indexer finished.  Test passed.  WaaHoo."
fi

#
#   Check the status.  The file being crawled is only
#   30K.  This should not take more than 5 minutes.
#   If it does, it is a bug.
#

#
#   Check the stats.
#
crawl_check $SHOST $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
