#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="service-check-1"
   DESCRIPTION="check running service for single document crawl"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

mewc=0
midc=0
mcrc=0
mqyc=0
mcsc=0
mcdc=0


cnt=1

if [ "$1" == "force" ]; then
   kill_all_services
   sleep 1
   kill_all_services
fi

aewc=`get_service_pid_count -S execute-worker`
aidc=`get_service_pid_count -S indexer`
acrc=`get_service_pid_count -S crawler`
aqyc=`get_service_pid_count -S query-all`
acsc=`get_service_pid_count -S collection-service-all`
acdc=`get_service_pid_count -S collection-service-dispatch`

echo "execute-worker count:               $aewc"
echo "indexer count:                      $aidc"
echo "crawler count:                      $acrc"
echo "query-service count:                $aqyc"
echo "collection-service count:           $acsc"
echo "collection-service-dispatch count:  $acdc"

if [ $aewc -ne 0 ] || [ $aidc -ne 0 ] || [ $acrc -ne 0 ] || \
   [ $aqyc -ne 2 ] || [ $acsc -ne 0 ]; then
   echo "Services running do not represent a quiet target system"
   echo "For this test to work, no crawlers or reindexing can"
   echo "be running on the target"
   echo "$VCOLLECTION:  Test Failed"
   exit 1
fi

#
#   New version has different results than old.
#
majorversion=`getmajorversion`

getsetopts $*

cleanup $SHOST $VCOLLECTION $VUSER $VPW
create_collection -C $VCOLLECTION

stime=`date +%s`
export VIVSTARTTIME=$stime

start_crawl -C $VCOLLECTION

sleep 2

while [ $cnt -le 30 ]; do
   bewc=`get_service_pid_count -S execute-worker`
   bidc=`get_service_pid_count -S indexer`
   bcrc=`get_service_pid_count -S crawler`
   bqyc=`get_service_pid_count -S query-all`
   bcsc=`get_service_pid_count -S collection-service-all`
   bcdc=`get_service_pid_count -S collection-service-dispatch`

   echo "INTERIM SERVICE CHECK:  $cnt of 30"
   echo "execute-worker count:               $bewc"
   echo "indexer count:                      $bidc"
   echo "crawler count:                      $bcrc"
   echo "query-service count:                $bqyc"
   echo "collection-service count:           $bcsc"
   echo "collection-service-dispatch count:  $bcdc"

   if [ $bewc -gt $mewc ]; then
      mewc=$bewc
   fi
   if [ $bidc -gt $midc ]; then
      midc=$bidc
   fi
   if [ $bcrc -gt $mcrc ]; then
      mcrc=$bcrc
   fi
   if [ $bqyc -gt $mqyc ]; then
      mqyc=$bqyc
   fi
   if [ $bcsc -gt $mcsc ]; then
      mcsc=$bcsc
   fi
   if [ $bcdc -gt $mcdc ]; then
      mcdc=$bcdc
   fi

   cnt=`expr $cnt + 1`
done

wait_for_idle -C $VCOLLECTION

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION ODBC
basic_query_test 2 $SHOST $VCOLLECTION main

echo ""
echo "RUNNING SERVICES MAXIMUMS"
echo "execute-worker count:               $mewc"
echo "indexer count:                      $midc"
echo "crawler count:                      $mcrc"
echo "query-service count:                $mqyc"
echo "collection-service count:           $mcsc"
echo "collection-service-dispatch count:  $mcdc"

casecount=`expr $casecount + 7`
if [ $mewc -ne 5 ]; then
   echo "execute-worker:  expected 5, found $mewc"
   results=`expr $results + 1`
fi

if [ $midc -ne 1 ]; then
   echo "indexer-service:  expected 1, found $midc"
   results=`expr $results + 1`
fi

if [ $mcrc -ne 1 ]; then
   echo "crawler-service:  expected 1, found $mcrc"
   results=`expr $results + 1`
fi

if [ $mqyc -ne 2 ]; then
   echo "query-service:  expected 2, found $mqyc"
   results=`expr $results + 1`
fi

if [ $mcsc -ne 1 ]; then
   echo "collection-service:  expected 1, found $mcsc"
   results=`expr $results + 1`
fi

if [ $mcdc -ne 1 ] && [ $mcdc -ne 2 ]; then
   echo "collection-service-dispatch:  expected 1 or 2, found $mcdc"
   results=`expr $results + 1`
fi

echo ""
echo "FINAL SERVICES CHECK"
aewc=`get_service_pid_count -S execute-worker`
aidc=`get_service_pid_count -S indexer`
acrc=`get_service_pid_count -S crawler`
aqyc=`get_service_pid_count -S query-all`
acsc=`get_service_pid_count -S collection-service-all`
acdc=`get_service_pid_count -S collection-service-dispatch`

echo "execute-worker count:               $aewc"
echo "indexer count:                      $aidc"
echo "crawler count:                      $acrc"
echo "query-service count:                $aqyc"
echo "collection-service count:           $acsc"
echo "collection-service-dispatch count:  $acdc"

if [ $aewc -ne 0 ] || [ $aidc -ne 1 ] || [ $acrc -ne 0 ] || \
   [ $aqyc -ne 2 ] || [ $acsc -ne 1 ]; then
   echo "Services running do not represent a quiet target system"
   echo "with one collection running normally."
   results=`expr $results + 1`
fi

source $TEST_ROOT/lib/run_std_results.sh
