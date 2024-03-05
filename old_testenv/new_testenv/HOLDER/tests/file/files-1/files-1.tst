#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="files-1"
   DESCRIPTION="file system(nfs) crawl and search of various doc types"

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
   echo "files-1: Test Failed"
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
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Hamilton
basic_query_test 2 $SHOST $VCOLLECTION Hamilton+Madison
basic_query_test 3 $SHOST $VCOLLECTION Linux
basic_query_test 4 $SHOST $VCOLLECTION Stinkybottom
basic_query_test 5 $SHOST $VCOLLECTION We+the+people
basic_query_test 6 $SHOST $VCOLLECTION Drahtmüller

diff_match_counts Hamilton
diff_match_counts Hamilton+Madison
diff_match_counts Linux
diff_match_counts Stinkybottom
diff_match_counts We+the+people
diff_match_counts Drahtmüller

diff_titles Hamilton
diff_titles Hamilton+Madison
diff_titles Linux
diff_titles Stinkybottom
diff_titles We+the+people
diff_titles Drahtmüller

source $TEST_ROOT/lib/run_std_results.sh
