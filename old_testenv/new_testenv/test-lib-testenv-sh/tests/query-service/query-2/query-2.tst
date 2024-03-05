#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="query-2"
   DESCRIPTION="Multiple users bring query service up and down"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   Preliminary checks that the query
#   service is, in fact, working correctly.
#
query_service_status -H $SHOST
if [ $? -ne 1 ]; then
   start_query_service -H $SHOST -U $VUSER -P $VPW
fi

basic_query_test 1 $SHOST $VCOLLECTION Arizona

#
#   Lauch scripts to start and stop the
#   query service.
#
./stopper.sh $SHOST $VUSER $VPW 3 &
stp=$!

./starter.sh $SHOST $VUSER $VPW 4 &
str=$!

./stop_start.sh $SHOST $VUSER $VPW 2 &
stpstr=$!

./stop_start.sh $SHOST $VUSER $VPW 3 &
stpstr2=$!

maxmax=200
iter=1
while [ $iter -le $maxmax ];do
   sleep 2
   echo "Pass $iter of $maxmax"
   query_service_status -H $SHOST
   if [ $? -eq 1 ];then
      echo "   Query service is up"
   else
      echo "   Query service is down"
   fi
   iter=`expr $iter + 1`
done

kill -9 $stpstr $stpstr2 $stp $str
sleep 2

#
#   Force restart of query service.  Restart
#   will fail if a disconnected query service is
#   running because the new service will not
#   be able to get the correct port and it
#   will die.
#
echo "Make sure query service is up"
start_query_service -H $SHOST -U $VUSER -P $VPW

casecount=`expr $casecount + 1`
#
#   Check the query service.  Should be up
#   at this point.  If it is not, or we
#   can not recognize that it is up,
#   we have a problem.
#
query_service_status -H $SHOST
if [ $? -ne 1 ]; then
   echo "Query service indicates down.  Should be up"
   results=`expr $results + 1`
   #
   #   Restart for next test
   #
   start_query_service -H $SHOST -U $VUSER -P $VPW
fi

#
#   function basic_query_test
#   args are test number, host, collection, query string
#   Test that query service is up by executing a query
#
basic_query_test 2 $SHOST $VCOLLECTION bismarck

source $TEST_ROOT/lib/run_std_results.sh
