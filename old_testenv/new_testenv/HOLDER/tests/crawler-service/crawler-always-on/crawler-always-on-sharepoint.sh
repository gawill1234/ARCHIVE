#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-always-on"
   VCOLLECTION3="crawler-always-on-sharepoint"
   DESCRIPTION="Repeated refresh crawl of sharepoint collection"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

speed=$1
maxrun=50
maxfail=10

if [ "$speed" == "" ]; then
   speed="slow"
fi

echo "SPEED:  $speed"

if [ "$speed" == "fast" ]; then
   maxrun=10
   maxfail=2
fi

#
#   New version has different results than old.
#
majorversion=`getmajorversion`

rm -f querywork/sharepoint-result

getsetopts $*

cleanup $SHOST $VCOLLECTION3 $VUSER $VPW

setup $SHOST $VCOLLECTION3 $VUSER $VPW

echo "####   Checking $VCOLLECTION3  ####"
crawl_check $SHOST $VCOLLECTION3

Hm=0
WtP=0
irq=0
jay=0
Or=0

oldres=0

runcnt=0
while [ $runcnt -lt $maxrun ]; do

   echo "Refresh run $runcnt"

   refresh_crawl -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW &

   wait_for_idle -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW

   if [ "$majorversion" -ge "6" ]; then
      merge_index -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW
      wait_for_idle -C $VCOLLECTION3 -H $SHOST -U $VUSER -P $VPW
   fi

   echo "####   Checking $VCOLLECTION3  --$runcnt--  ####"
   crawl_check_nv $SHOST $VCOLLECTION3
   #
   #   function basic_query_test
   #   args are test number, host, collection, query string
   #

   echo "####   $VCOLLECTION3 Queries   --$runcnt--  ####"
   oldres=$results
   basic_query_test 1 $SHOST $VCOLLECTION3 Hamilton
   if [ $oldres -ne $results ]; then
      Hm=`expr $Hm + 1`
   fi

   oldres=$results
   basic_query_test 2 $SHOST $VCOLLECTION3 We+the+people
   if [ $oldres -ne $results ]; then
      WtP=`expr $WtP + 1`
   fi

   oldres=$results
   basic_query_test 3 $SHOST $VCOLLECTION3 iroquois
   if [ $oldres -ne $results ]; then
      irq=`expr $irq + 1`
   fi

   oldres=$results
   basic_query_test 4 $SHOST $VCOLLECTION3 jay
   if [ $oldres -ne $results ]; then
      jay=`expr $jay + 1`
   fi

   oldres=$results
   basic_query_test 5 $SHOST $VCOLLECTION3 Orion
   if [ $oldres -ne $results ]; then
      Or=`expr $Or + 1`
   fi

   runcnt=`expr $runcnt + 1`
done

if [ $Hm -le $maxfail ]; then
   results=`expr $results - $Hm`
   echo "Hamilton query failed $Hm times (within accepted tolerance)."
else
   echo "Hamilton query failed $Hm times."
fi
if [ $WtP -le $maxfail ]; then
   results=`expr $results - $WtP`
   echo "We+the+People query failed $WtP times (within accepted tolerance)."
else
   echo "We+the+People query failed $WtP times."
fi
if [ $irq -le $maxfail ]; then
   results=`expr $results - $irq`
   echo "iroquois query failed $irq times (within accepted tolerance)."
else
   echo "iroquois query failed $irq times."
fi
if [ $jay -le $maxfail ]; then
   results=`expr $results - $jay`
   echo "jay query failed $jay times (within accepted tolerance)."
else
   echo "jay query failed $jay times."
fi
if [ $Or -le $maxfail ]; then
   results=`expr $results - $Or`
   echo "Orion query failed $Or times (within accepted tolerance)."
else
   echo "Orion query failed $Or times."
fi

echo "$DESCRIPTION: exit($results)"
if [ $results -eq 0 ]; then
   echo "PASSED" > querywork/sharepoint-result
else
   echo "FAILED" > querywork/sharepoint-result
fi
exit $results
