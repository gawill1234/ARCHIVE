#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTIONA="controller-coverage-web-a"
   DESCRPTIONA="Filtering rule"
   VCOLLECTIONB="controller-coverage-web-b"
   DESCRPTIONB="Max 10 URLs"
   VCOLLECTIONC="controller-coverage-web-c"
   DESCRIPTIONC="Max 10 input URLs"
   VCOLLECTIOND="controller-coverage-web-d"
   DESCRIPTIOND="Max 10 documents"
   VCOLLECTIONE="controller-coverage-web-e"
   DESCRIPTIONE="Max running time 20 secs"
   VCOLLECTIONF="controller-coverage-web-f"
   DESCRIPTIONF="Disable resume"
   VCOLLECTIONG="controller-coverage-web-g"
   DESCRIPTIONG="Disable URL browsing"
   VCOLLECTIONH="controller-coverage-web-h"
   DESCRIPTIONH="Disable graph logging"
   VCOLLECTIONI="controller-coverage-web-i"
   DESCRIPTIONI="Disable graph logging and resume"
   VCOLLECTIONJ="controller-coverage-web-j"
   DESCRIPTIONJ="Negative status update time"
   VCOLLECTIONK="controller-coverage-web-k"
   DESCRIPTIONK="Redirects and error"
   VCOLLECTION0="controller-coverage-web-slow"
   DESCRIPTION0="slower crawl for kill + resume experiments"
   VCOLLECTION1="controller-coverage-web-refresh"
   DESCRIPTION1="crawl, filter urls, refresh"
   DESCRIPTION="controller coverage test"
###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

getsetopts $*

cleanup_setup_and_test()
{
    test_header $1 $2 
    cleanup $SHOST $1 $VUSER $VPW
    setup $SHOST $1 $VUSER $VPW
    crawler_status -C $1
    x=$?
    if [ $x -ne 0 ]; then
      echo "Test failed for collection $1"
    fi
}

cleanup_setup_and_test_no_wait()
{
    test_header $1 $2
    cleanup $SHOST $1 $VUSER $VPW
    setup_no_wait $SHOST $1 $VUSER $VPW
    crawler_status -C $1
    x=$?
    if [ $x -ne 0 ]; then
      echo "Test failed for collection $1"
    fi
}


cleanup_setup_and_test $VCOLLECTIONA $DESCRIPTIONA
cleanup_setup_and_test $VCOLLECTIONB $DESCRIPTIONB
cleanup_setup_and_test $VCOLLECTIONC $DESCRIPTIONC
cleanup_setup_and_test $VCOLLECTIOND $DESCRIPTIOND
cleanup_setup_and_test $VCOLLECTIONE $DESCRIPTIONE
cleanup_setup_and_test $VCOLLECTIONF $DESCRIPTIONF
cleanup_setup_and_test $VCOLLECTIONG $DESCRIPTIONG
cleanup_setup_and_test $VCOLLECTIONH $DESCRIPTIONH
cleanup_setup_and_test $VCOLLECTIONI $DESCRIPTIONI
cleanup_setup_and_test $VCOLLECTIONJ $DESCRIPTIONJ
cleanup_setup_and_test $VCOLLECTIONK $DESCRIPTIONK

cleanup_setup_and_test_no_wait $VCOLLECTION0 $DESCRIPTION0
sleep 10
stop_crawler -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW -K no
sleep 10
resume_crawl -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW
wait_for_idle -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW

#kill it, resume
start_crawl -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW
sleep 10
stop_crawler -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW -f
sleep 10
resume_crawl -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW
wait_for_idle -C $VCOLLECTION0 -H $SHOST -U $VUSER -P $VPW

cp controller-coverage-web-refresh.xml.no-filter controller-coverage-web-refresh.xml
cleanup_setup_and_test $VCOLLECTION1 $DESCRIPTION1
sleep 10
cp controller-coverage-web-refresh.xml.filtered controller-coverage-web-refresh.xml
sleep 10
echo "Removing collection..."
remove_collection -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
sleep 10
echo "Creating new collection..."
create_collection -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
sleep 10
echo "Refreshing crawl..."
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW

#if [ $results -eq 0 ]; then
   cleanup $SHOST $VCOLLECTIONA $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONB $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONC $VUSER $VPW
   cleanup $SHOST $VCOLLECTIOND $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONE $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONF $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONG $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONH $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONI $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONJ $VUSER $VPW
   cleanup $SHOST $VCOLLECTIONK $VUSER $VPW
   cleanup $SHOST $VCOLLECTION0 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION1 $VUSER $VPW
#else
#   kill_service_children -C $VCOLLECTIONA -S indexer
#   kill_service_children -C $VCOLLECTIONB -S indexer
#   kill_service_children -C $VCOLLECTIONC -S indexer
#   kill_service_children -C $VCOLLECTIOND -S indexer
#   kill_service_children -C $VCOLLECTIONE -S indexer
#   kill_service_children -C $VCOLLECTIONF -S indexer
#   kill_service_children -C $VCOLLECTIONG -S indexer
#   kill_service_children -C $VCOLLECTIONH -S indexer
#   kill_service_children -C $VCOLLECTIONI -S indexer
#   kill_service_children -C $VCOLLECTIONJ -S indexer
#   kill_service_children -C $VCOLLECTIONK -S indexer
#   kill_service_children -C $VCOLLECTION0 -S indexer
#   kill_service_children -C $VCOLLECTION1 -S indexer
#fi
source $TEST_ROOT/lib/run_std_results.sh
