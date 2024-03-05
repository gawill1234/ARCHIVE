#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="10253"
   DESCRIPTION="10253 bug test"

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

cleanup $SHOST $VCOLLECTION $VUSER $VPW

create_collection -C $VCOLLECTION
stime=`date +%s`
export VIVSTARTTIME=$stime
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
      echo "Waited for crawl for 5 minutes.  It did not finish."
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
   echo "Crawl finished.  Test passed.  WaaHoo."
fi

crawl_check $SHOST $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
