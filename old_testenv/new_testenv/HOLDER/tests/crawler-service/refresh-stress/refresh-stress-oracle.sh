#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="refresh-stress"
   VCOLLECTION1="refresh-stress-oracle"
   DESCRIPTION="Repeated refresh crawl of oracle collection"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

speed=$1
maxrun=100
maxfail=15

if [ "$speed" == "" ]; then
   speed="slow"
fi

echo "SPEED:  $speed"

if [ "$speed" == "fast" ]; then
   maxrun=20
   maxfail=3
fi

rm -f querywork/oracle-result

getsetopts $*

cleanup $SHOST $VCOLLECTION1 $VUSER $VPW

setup $SHOST $VCOLLECTION1 $VUSER $VPW

echo "####   Checking $VCOLLECTION1  ####"
crawl_check $SHOST $VCOLLECTION1

Az=0
AzB=0
bk=0
az=0
Bl=0

oldres=0

runcnt=0
while [ $runcnt -lt $maxrun ]; do

   echo "Refresh run $runcnt"

   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &

   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW

   echo "####   Checking $VCOLLECTION1  --$runcnt--  ####"
   crawl_check_nv $SHOST $VCOLLECTION1
   #
   #   function basic_query_test
   #   args are test number, host, collection, query string
   #
   echo "####   $VCOLLECTION1 Queries   --$runcnt--  ####"
   oldres=$results
   basic_query_test 1 $SHOST $VCOLLECTION1 Arizona
   if [ $oldres -ne $results ]; then
      Az=`expr $Az + 1`
   fi

   oldres=$results
   basic_query_test 2 $SHOST $VCOLLECTION1 Arizona+Battleship
   if [ $oldres -ne $results ]; then
      AzB=`expr $AzB + 1`
   fi

   oldres=$results
   basic_query_test 3 $SHOST $VCOLLECTION1 bismarck
   if [ $oldres -ne $results ]; then
      bk=`expr $bk + 1`
   fi

   oldres=$results
   basic_query_test 4 $SHOST $VCOLLECTION1 arizona
   if [ $oldres -ne $results ]; then
      az=`expr $az + 1`
   fi

   oldres=$results
   basic_query_test 5 $SHOST $VCOLLECTION1 Blücher
   if [ $oldres -ne $results ]; then
      Bl=`expr $Bl + 1`
   fi

   runcnt=`expr $runcnt + 1`
done

if [ $Az -le $maxfail ]; then
   results=`expr $results - $Az`
   echo "Arizona query failed $Az times (within accepted tolerance)."
else
   echo "Arizona query failed $Az times."
fi
if [ $AzB -le $maxfail ]; then
   results=`expr $results - $AzB`
   echo "Arizona+Battleship query failed $AzB times (within accepted tolerance)."
else
   echo "Arizona+Battleship query failed $AzB times."
fi
if [ $bk -le $maxfail ]; then
   results=`expr $results - $bk`
   echo "bismarck query failed $bk times (within accepted tolerance)."
else
   echo "bismarck query failed $bk times."
fi
if [ $az -le $maxfail ]; then
   results=`expr $results - $az`
   echo "arizona query failed $az times (within accepted tolerance)."
else
   echo "arizona query failed $az times."
fi
if [ $Bl -le $maxfail ]; then
   results=`expr $results - $Bl`
   echo "Blücher query failed $Bl times (within accepted tolerance)."
else
   echo "Blücher query failed $Bl times."
fi

echo "$DESCRIPTION: exit($results)"
if [ $results -eq 0 ]; then
   echo "PASSED" > querywork/oracle-result
else
   echo "FAILED" > querywork/oracle-result
fi
exit $results
