#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="simultaneous-query"
   DESCRIPTION="simultaneous queries of the same collection"

###
###

export VIVDEFCONVERT="true"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

max=10
thisone=0
while [ $thisone -lt $max ]; do
   echo "Launching query processes"
   sq_queryit
   thisone=`expr $thisone + 1`
done

#
#   If any of the processes are left over, kill them
#
pkill -9 sq_queryit

sleep 2

source $TEST_ROOT/lib/run_std_results.sh
