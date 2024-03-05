#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="ldds_continuous_crawl"
   DESCRIPTION="Refresh with concurrent queries"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################
test_header $VCOLLECTION $DESCRIPTION

speed=$1
if [ "$speed" == "" ]; then
   speed="slow"
fi

echo "SPEED:  $speed"

if [ -f /testenv/CHECKFILE ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "refresh-stress: Test Failed"
   exit 1
fi

getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW

create_collection -C $VCOLLECTION -H $SHOST
stime=`date +%s`
export VIVSTARTTIME=$stime
start_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

wait_for_idle -C $VCOLLECTION

while [ 1 ]; do
   refresh_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION
done

exit 1
