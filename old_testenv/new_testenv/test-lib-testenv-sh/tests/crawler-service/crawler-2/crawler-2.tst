#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-2"
   VCOLLECTION1="crawler-2-sharepoint"
   DESCRIPTION="Repeated refresh crawl after interruption"

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

getsetopts $*

cleanup $SHOST $VCOLLECTION1 $VUSER $VPW

setup $SHOST $VCOLLECTION1 $VUSER $VPW

crawl_check $SHOST $VCOLLECTION1

runcnt=0
while [ $runcnt -lt 25 ]; do

   echo "Refresh run $runcnt"

   sleep 1
   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   get_status -H $SHOST -C $VCOLLECTION1 -U $VUSER -P $VPW
   newrun=$?
   if [ $newrun -le 1 ]; then
      echo "Refresh failed:  Trying again."
      sleep 1
      refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   fi
   sleep 1
   stop_crawler -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW -f

   if [ -f crawler-2-sharepoint.stpclog ]; then
      mv -f crawler-2-sharepoint.stpclog querywork/crawler-2-sharepoint.stpclog
   fi
   if  [ -f crawler-2-sharepoint.stpcout ]; then
      mv -f crawler-2-sharepoint.stpcout querywork/crawler-2-sharepoint.stpcout
   fi

   runcnt=`expr $runcnt + 1`
done

refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
get_status -H $SHOST -C $VCOLLECTION1 -U $VUSER -P $VPW
newrun=$?
if [ $newrun -le 1 ]; then
   echo "Refresh failed:  Trying again."
   sleep 1
   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
fi

wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW

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
