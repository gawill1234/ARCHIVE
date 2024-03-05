#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-3"
   VCOLLECTION1="crawler-3-sharepoint"
   DESCRIPTION="Repeated resume crawl after interruption"

###
###

export VIVDEFCONVERT="true"

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="crawler"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#  Default version to 6.0 or greater
#
if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

bailout=0
if [ "$1" == "bail" ]; then
  bailout=1
fi

getsetopts $*

cleanup $SHOST $VCOLLECTION1 $VUSER $VPW

setup $SHOST $VCOLLECTION1 $VUSER $VPW

crawl_check $SHOST $VCOLLECTION1

refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW

runcnt=0
while [ $runcnt -lt 25 ]; do

   echo "Resume run $runcnt"

   sleep 1
   stop_crawler -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW -f
   sleep 1
   resume_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   get_status -H $SHOST -C $VCOLLECTION1 -U $VUSER -P $VPW
   newrun=$?
   if [ $newrun -le 1 ]; then
      echo "Resume failed:  Trying again."
      sleep 1
      resume_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   else
      if [ $newrun -eq 3 ]; then
         echo "Crawler running, indexer is running."
      fi
      if [ $newrun -eq 2 ]; then
         echo "Crawl completed, indexer is running."
         runcnt=101
      fi
      if [ $newrun -eq 3 ]; then
         echo "Crawler running, indexer is running."
      fi
   fi
   if [ $bailout -eq 1 ]; then
      runcnt=101
   else
      runcnt=`expr $runcnt + 1`
   fi
done

echo "OUT OF LOOP, Getting status and waiting ..."
get_status -H $SHOST -C $VCOLLECTION1 -U $VUSER -P $VPW
newrun=$?
if [ $newrun -gt 1 ]; then
   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   wfistat=$?
   if [ $wfistat -eq 2 ]; then
      echo "Something is hung, exiting"
      echo "$VCOLLECTION:  Test Failed"
      exit 1
   fi
fi

crawl_check_nv $SHOST $VCOLLECTION1

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION1 Hamilton
basic_query_test 2 $SHOST $VCOLLECTION1 We+the+people
basic_query_test 3 $SHOST $VCOLLECTION1 iroquois
basic_query_test 4 $SHOST $VCOLLECTION1 jay
basic_query_test 5 $SHOST $VCOLLECTION1 Orion

source $TEST_ROOT/lib/run_std_results.sh
