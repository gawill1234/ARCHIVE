#!/bin/bash

#####################################################################

###
#   Global stuff
###

#
#   This tests is a crawl only test.  It crawl a large data set
#   and checks the results of the crawl numbers.  This test does
#   not delete the target collection as it is a prerequisite to
#   other search tests.  This is done because this crawl takes an
#   extended period of time and we would rather not repeat the crawl
#   unless it is required.
#
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="files-2"
   DESCRIPTION="file system(nfs) crawl(only) of many(700K) html docs"

###
###

export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#   Check for the existence of the file system on the target
#
fe=`file_exists -F /testenv/CHECKFILE`
if [ $fe -eq 1 ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "files-2: Test Failed"
   exit 1
fi

if [ ! -z $VIVTARGETARCH ]; then
   if [ "$VIVTARGETARCH" != "linux64" ] && [ "$VIVTARGETARCH" != "linux32" ]; then
      echo "Test passes because it can not be run on target architecture:  $VIVTARGETARCH"
      echo "$VCOLLECTION:  Test Failed"
      exit 1
   fi
else
   echo "Unknown target architecture.  Set environment variable"
   echo "VIVTARGETARCH.  Valid values are linux32, linux64,"
   echo "windows32, window64, solaris32 or solaris64."
   echo "However, this test only works with linux64 and linux32."
   echo "$VCOLLECTION:  Test Failed"
   exit 1
fi

majorversion=`getmajorversion`

if [ "$majorversion" -lt "6" ]; then
   echo "Test not valid for version older than 6.0"
   exit 0
fi

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   Delete the collection only if the test fails.  This will force 
#   dependent tests to rerun this test in an attempt to get proper
#   results
#
export VIVDELETE="fail"

source $TEST_ROOT/lib/run_std_results.sh
