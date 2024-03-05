#!/bin/bash

#####################################################################
#
#   This test uses XMLStarlet Toolkit to validate the repository.
#   If your machine does not have this, the test will fail.
#

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="validation-check"
   DESCRIPTION="Make sure repository xml is valid (well formed only)"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

MajV=`getmajorversion`

if [ $MajV -ge 7 ]; then
   get_repository -I
   xml val repository-internal.xml
   xx=$?
else
   get_repository
   xml val repository.xml
   xx=$?
fi

if [ $xx -eq 0 ]; then
   echo "validation-check:  Test Passed"
   exit 0
fi

echo "validation-check:  Test Failed"
exit 1


