#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="duplicates-1"
   VCOLLECTION1="duplicate-test-1"
   VCOLLECTION2="duplicate-test-2"
   VCOLLECTION3="duplicate-test-3"
   VCOLLECTION4="duplicate-test-4"
   VCOLLECTION5="duplicate-test-5"
   VCOLLECTION6="duplicate-test-6"
   VCOLLECTION7="duplicate-test-7"
   VCOLLECTION8="duplicate-test-8"
   DESCRIPTION="Repeated refresh crawl of multiple collections"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

getsetopts $*

cleanup $SHOST $VCOLLECTION1 $VUSER $VPW
cleanup $SHOST $VCOLLECTION2 $VUSER $VPW
cleanup $SHOST $VCOLLECTION3 $VUSER $VPW
cleanup $SHOST $VCOLLECTION4 $VUSER $VPW
cleanup $SHOST $VCOLLECTION5 $VUSER $VPW
cleanup $SHOST $VCOLLECTION6 $VUSER $VPW
cleanup $SHOST $VCOLLECTION7 $VUSER $VPW
cleanup $SHOST $VCOLLECTION8 $VUSER $VPW

setup $SHOST $VCOLLECTION1 $VUSER $VPW
setup $SHOST $VCOLLECTION2 $VUSER $VPW
setup $SHOST $VCOLLECTION3 $VUSER $VPW
setup $SHOST $VCOLLECTION4 $VUSER $VPW
setup $SHOST $VCOLLECTION5 $VUSER $VPW
setup $SHOST $VCOLLECTION6 $VUSER $VPW
setup $SHOST $VCOLLECTION7 $VUSER $VPW
setup $SHOST $VCOLLECTION8 $VUSER $VPW

crawl_check $SHOST $VCOLLECTION1
crawl_check $SHOST $VCOLLECTION2
crawl_check $SHOST $VCOLLECTION3
crawl_check $SHOST $VCOLLECTION4
crawl_check $SHOST $VCOLLECTION5
crawl_check $SHOST $VCOLLECTION6
crawl_check $SHOST $VCOLLECTION7
crawl_check $SHOST $VCOLLECTION8

if [ $results -eq 0 ]; then
   cleanup $SHOST $VCOLLECTION1 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION2 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION3 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION4 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION5 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION6 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION7 $VUSER $VPW
   cleanup $SHOST $VCOLLECTION8 $VUSER $VPW
else
   kill_service_children -C $VCOLLECTION1 -S indexer
   kill_service_children -C $VCOLLECTION2 -S indexer
   kill_service_children -C $VCOLLECTION3 -S indexer
   kill_service_children -C $VCOLLECTION4 -S indexer
   kill_service_children -C $VCOLLECTION5 -S indexer
   kill_service_children -C $VCOLLECTION6 -S indexer
   kill_service_children -C $VCOLLECTION7 -S indexer
   kill_service_children -C $VCOLLECTION8 -S indexer
fi

source $TEST_ROOT/lib/run_std_results.sh
