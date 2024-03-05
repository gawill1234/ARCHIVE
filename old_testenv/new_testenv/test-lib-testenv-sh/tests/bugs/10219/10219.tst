#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="10219"
   DESCRIPTION="Bad anchors do not cause a crash"

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

if [ $majorversion -lt 6 ]; then
   echo "Test Passed because it is no valid for this version of Velocity"
   exit 0
fi

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

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

rm ${VCOLLECTION}.xml

source $TEST_ROOT/lib/run_std_results.sh
