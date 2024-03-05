#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   TESTNAME="crawler-5"
   DESCRIPTION="Repeated resume crawl after crawl crash"
   VCOLLECTION="crawler-5-samba"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="crawler"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $TESTNAME $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

getsetopts $*

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

cleanup $SHOST $VCOLLECTION $VUSER $VPW

setup_no_wait $SHOST $VCOLLECTION $VUSER $VPW

myst=1
runcnt=0
while [ $runcnt -lt 100 ]; do

   sleepval=`genrand -M 90 -m 1`

   echo "Wait $sleepval seconds before stopping crawler"
   sleep $sleepval

   get_status -H $SHOST -C $VCOLLECTION -U $VUSER -P $VPW
   myst=$?

   if [ $myst -eq 3 ]; then
      echo "Resume run $runcnt"

      stop_crawler -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW -f
      if [ -f $VCOLLECTION.stpcout ]; then
         mv $VCOLLECTION.stpcout querywork/$VCOLLECTION.stpcout
      fi
      if [ -f $VCOLLECTION.stpclog ]; then
         mv $VCOLLECTION.stpclog querywork/$VCOLLECTION.stpclog
      fi
      sleep 2
      resume_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
      get_status -H $SHOST -C $VCOLLECTION -U $VUSER -P $VPW
      newrun=$?
      if [ $newrun -le 1 ]; then
         echo "Resume failed:  Trying again."
         sleep 1
         resume_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
      fi
      runcnt=`expr $runcnt + 1`
   else
      if [ $myst -le 1 ]; then
         echo "Crawl completed or did not resume correctly"
      fi
      if [ $myst -eq 2 ]; then
         echo "Crawl completed, indexer is running."
      fi
      runcnt=101
   fi

done

if [ $myst -ne 0 ]; then
   wait_for_idle -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
fi

mv $VCOLLECTION.crwllog querywork/$VCOLLECTION.crwllog
mv $VCOLLECTION.crwlout querywork/$VCOLLECTION.crwlout

crawl_check_nv $SHOST $VCOLLECTION

for file in query_cmp_files/qry*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#basic_query_test 1 $SHOST $VCOLLECTION Hamilton
#basic_query_test 2 $SHOST $VCOLLECTION Hamilton+Madison
#basic_query_test 3 $SHOST $VCOLLECTION Linux
#basic_query_test 4 $SHOST $VCOLLECTION We+the+people
#basic_query_test 5 $SHOST $VCOLLECTION Stinkybottom

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
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton+Madison" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Linux" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "We+the+people" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
casecount=`expr $casecount + 1`
results=`expr $results + $xx`

rm ${VCOLLECTION}.xml
rm query_cmp_files/qry*

source $TEST_ROOT/lib/run_std_results.sh
