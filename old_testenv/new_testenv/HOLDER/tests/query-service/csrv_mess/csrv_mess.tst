#!/bin/bash

#####################################################################
#
#   Crawl directories approximately 26+ levels deep.  Tests samba
#   levels as well as non-default crawl hops.
#
#   All told, there are less than 200 documents in this crawl so
#   all matched urls should be in the returned queries.
#

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="csrv_mess"
   DESCRIPTION="Beat on the collection service to make it start wrong"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ "$VIVTARGETOS" == "windows" ]; then
   echo "This test does not work on a windows install"
   echo "csrv_mess:  Test Not Applicable"
   exit 1
fi

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Meridian
basic_query_test 2 $SHOST $VCOLLECTION McIntosh
basic_query_test 3 $SHOST $VCOLLECTION Adcom
basic_query_test 4 $SHOST $VCOLLECTION Stinkybottom
basic_query_test 5 $SHOST $VCOLLECTION Cary+Audio
basic_query_test 6 $SHOST $VCOLLECTION adcom+mcintosh

./run_queries.sh &
buzz=$!
countflag=0
zzz=0


while [ $zzz -lt 20 ]; do
   zzz=`expr $zzz + 1`
   sleep 10
   x=`get_service_pid_list -S collection-service-dispatch`
   y=`get_service_pid_list -S collection-service -C csrv_mess`

   for item in $x; do
      kill_service_children -S supplied -p $item
   done

   count=0
   for item in $y; do
      count=`expr $count + 1`
      kill_service_children -S supplied -p $item
   done

   if [ $count -gt 1 ]; then
      echo "Test Failed: $count collection-services, should be 1"
      countflag=`expr $countflag + 1`
      break
   fi
done

echo "Wait for the queries to quit"
wait $buzz

if [ $countflag -eq 0 ]; then
   echo "csrv_mess:  Test Passed"
   cleanup $SHOST $VCOLLECTION $VUSER $VPW
   exit 0
fi

echo "csrv_mess:  Test Failed"
exit 1
