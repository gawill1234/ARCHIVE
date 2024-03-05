#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="refresh-stress-fs"
   DESCRIPTION="Refresh filesystem with concurrent queries"

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

if [ -f /testenv/samba_test_data/refresh-stress/stable/us_doi.pdf ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "refresh-stress: Test Failed"
   exit 1
fi

mkdir -p querywork

./refresh-stress-files.sh $speed 1> querywork/files_output 2> querywork/files_output_err&
rsfiles=$!
echo "FILES:  $rsfiles"

sleep 2

echo "Wait for test parts to complete.  This will be awhile"
echo "Even if you said fast, this will still take 25 minutes"
echo "Waiting ..."
wait $rsfiles
filexit=$?

finalstat=`expr $filexit`

if [ $finalstat -eq 0 ]; then
   delete_collection -C refresh-stress-files
   echo "refresh-stress:  Test Passed"
   exit 0
else
   echo "files refresh:  exit($filexit)"
   echo "refresh-stress-fs:  Test Failed"
   stop_indexing -C refresh-stress-files
fi

exit 1
