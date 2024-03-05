#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-1"
   VCOLLECTION1="crawler-1-oracle"
   VCOLLECTION2="crawler-1-postgres"
   VCOLLECTION3="crawler-1-sharepoint"
   DESCRIPTION="Repeated refresh crawl of multiple collections"

###
###

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
cleanup $SHOST $VCOLLECTION2 $VUSER $VPW
cleanup $SHOST $VCOLLECTION3 $VUSER $VPW

setup $SHOST $VCOLLECTION1 $VUSER $VPW
setup $SHOST $VCOLLECTION2 $VUSER $VPW

export VIVDEFCONVERT="true"
setup $SHOST $VCOLLECTION3 $VUSER $VPW
export VIVDEFCONVERT="false"

echo "####   Checking $VCOLLECTION1  ####"
crawl_check $SHOST $VCOLLECTION1
echo "####   Checking $VCOLLECTION2  ####"
crawl_check $SHOST $VCOLLECTION2
echo "####   Checking $VCOLLECTION3  ####"
crawl_check $SHOST $VCOLLECTION3

runcnt=0
while [ $runcnt -lt 100 ]; do

   echo "Refresh run $runcnt"

   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
   refresh_crawl -C $VCOLLECTION2 -H $SHOST -U $VUSER -P $VPW &
   refresh_crawl -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW &

   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   wait_for_idle -C $VCOLLECTION2 -H $SHOST -U $VUSER -P $VPW
   wait_for_idle -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW

   if [ "$majorversion" -ge "6" ]; then
      merge_index -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW
      wait_for_idle -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW
   fi

   echo "####   Checking $VCOLLECTION1  --$runcnt--  ####"
   crawl_check_nv $SHOST $VCOLLECTION1
   echo "####   Checking $VCOLLECTION2  --$runcnt--  ####"
   crawl_check_nv $SHOST $VCOLLECTION2
   echo "####   Checking $VCOLLECTION3  --$runcnt--  ####"
   crawl_check_nv $SHOST $VCOLLECTION3
   #
   #   function basic_query_test
   #   args are test number, host, collection, query string
   #
   echo "####   $VCOLLECTION1 Queries   --$runcnt--  ####"
   basic_query_test 1 $SHOST $VCOLLECTION1 Arizona
   basic_query_test 2 $SHOST $VCOLLECTION1 Arizona+Battleship
   basic_query_test 3 $SHOST $VCOLLECTION1 bismarck
   basic_query_test 4 $SHOST $VCOLLECTION1 arizona
   #basic_query_test 5 $SHOST $VCOLLECTION1 Blücher

   echo "####   $VCOLLECTION2 Queries   --$runcnt--  ####"
   basic_query_test 1 $SHOST $VCOLLECTION2 Arizona
   basic_query_test 2 $SHOST $VCOLLECTION2 Arizona+Battleship
   basic_query_test 3 $SHOST $VCOLLECTION2 bismarck
   basic_query_test 4 $SHOST $VCOLLECTION2 arizona
   basic_query_test 5 $SHOST $VCOLLECTION2 Blücher

   echo "####   $VCOLLECTION3 Queries   --$runcnt--  ####"
   basic_query_test 1 $SHOST $VCOLLECTION3 Hamilton
   basic_query_test 2 $SHOST $VCOLLECTION3 We+the+people
   basic_query_test 3 $SHOST $VCOLLECTION3 iroquois
   basic_query_test 4 $SHOST $VCOLLECTION3 jay
   basic_query_test 5 $SHOST $VCOLLECTION3 Orion

   runcnt=`expr $runcnt + 1`
done


source $TEST_ROOT/lib/run_std_results.sh
