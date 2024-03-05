#!/bin/bash

#####################################################################

###
#   Global stuff
#
#   This test creates a collection and starts a crawl.
#   After the crawl is started, it periodically kills the
#   crawler and resumes it after short pause.
#   It kills the crawler up to 100 times, then
#   waits for the remainder of the crawl to finish.  After
#   the crawl completes a number if queries are issued which
#   should return the known correct results
#
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-die"
   DESCRIPTION="Crawl and query collection while killing/resuming crawler"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="crawler indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

MAXITER=100

majorversion=`getmajorversion`

if [ "$majorversion" -lt "6" ]; then
   echo "Test not valid for version older than 6.0"
   exit 0
fi

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

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
get_status -C $VCOLLECTION
x=$?

count=1
while [ $x -eq 3 ]; do
   echo "Iteration:  $count"
   echo "Current status value:  $x"
   sleepval=`genrand -M 90 -m 5`
   echo "Kill crawler and then wait $sleepval seconds"
   y=`get_crawler_pid -C $VCOLLECTION`
   if [ "$y" != "" ]; then
      kill_service_children -C $VCOLLECTION -S supplied -p $y
      sleep 1
      resume_crawl -C $VCOLLECTION
      sleep $sleepval
   fi
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

for file in query_cmp_files/qry*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

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

rm ${VCOLLECTION}.xml
rm query_cmp_files/qry*

source $TEST_ROOT/lib/run_std_results.sh
