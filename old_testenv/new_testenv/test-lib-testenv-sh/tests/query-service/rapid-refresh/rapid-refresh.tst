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

   VCOLLECTION="rapid-refresh"
   DESCRIPTION="Rapid refresh of single url collection"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

wait_for_idle -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

crawl_check $SHOST $VCOLLECTION

count=0
while [ $count -lt 250 ]; do
   sleep 1
   refresh_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW &
   count=`expr $count + 1`
   echo $count
done

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION ""
basic_query_test 2 $SHOST $VCOLLECTION Seven
basic_query_test 3 $SHOST $VCOLLECTION Audio
basic_query_test 4 $SHOST $VCOLLECTION Electronic+Supply
basic_query_test 5 $SHOST $VCOLLECTION midas

wait_for_idle -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

crawl_check_nv $SHOST $VCOLLECTION

export VIVERRORREPORT='False'

source $TEST_ROOT/lib/run_std_results.sh
