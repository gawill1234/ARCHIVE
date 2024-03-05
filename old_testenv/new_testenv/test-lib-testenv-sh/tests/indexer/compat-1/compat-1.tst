#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="CompatBrowse"
   DESCRIPTION="Copy old index to new install and query"

###
###

export VIVRUNTARGET="linux64"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW

targetdir=`vivisimo_dir -d collections`

if [ ! -z $VIVTARGETARCH ]; then
   if [ -d $VIVTARGETARCH ]; then
      put_dir -F $VIVTARGETARCH -D $targetdir
   else
      echo "Specified architecture directory does not exist: $VIVTARGETARCH"
      echo "This test only work with linux64."
      if [ "$VIVTARGETARCH" == "linux64" ]; then
         echo "$VCOLLECTION:  Test Failed"
         exit 1
      else
         echo "$VCOLLECTION:  Test Failed"
         echo "$VCOLLECTION:     But not really, not linux64"
         exit 1
      fi
   fi
else
   echo "Unknown target architecture.  Set environment variable"
   echo "VIVTARGETARCH.  Valid values are linux32, linux64,"
   echo "windows32, window64, solaris32 or solaris64."
   echo "However, this test only works with linux64."
   echo "$VCOLLECTION:  Test Failed"
   exit 1
fi

stime=`date +%s`
export VIVSTARTTIME=$stime

sleep 5

build_index -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION ""
basic_query_test 1 $SHOST $VCOLLECTION "Requirements"

source $TEST_ROOT/lib/run_std_results.sh
