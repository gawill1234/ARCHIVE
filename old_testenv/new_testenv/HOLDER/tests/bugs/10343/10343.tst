#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="10343"
   DESCRIPTION="test for bug 10343"

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

xx=`crawl_outputs -C $VCOLLECTION`
echo $xx

if [ $xx -eq 2 ]; then

   refresh_crawl -C $VCOLLECTION

   wait_for_idle -C $VCOLLECTION

   xx=`crawl_outputs -C $VCOLLECTION`
   echo $xx
   if [ $xx -eq 0 ]; then
      echo "10343:  Test Passed"
      exit 0
   else
      echo "Crawler failed.  Expected 2 documents, got $xx"
      echo "10343:  Test Failed"
      exit 1
   fi
else
   echo "Crawler failed.  Expected 2 documents, got $xx"
   echo "10343:  Test Failed"
   exit 1
fi

echo "10343:  Test Failed"
exit 1
