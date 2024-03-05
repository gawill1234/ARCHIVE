#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6263-compat"
   VCOLLECTION_REMOTE="6263-compat-remote"
   DESCRIPTION="Copy old index to new install and query with remote collection"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

getsetopts $*

cleanup $SHOST $VCOLLECTION $VUSER $VPW
cleanup $SHOST $VCOLLECTION_REMOTE $VUSER $VPW

targetdir=`vivisimo_dir -d collections`

if [ ! -z $VIVTARGETARCH ]; then
   if [ -d $VIVTARGETARCH ]; then
      put_dir -F $VIVTARGETARCH -D $targetdir
   else
      echo "Specified architecture directory does not exist: $VIVTARGETARCH"
      echo "$VCOLLECTION:  Test Failed"
      exit 1
   fi
else
   echo "Unknown target architecture.  Set environment variable"
   echo "VIVTARGETARCH.  Valid values are linux32, linux64,"
   echo "windows32, window64, solaris32 or solaris64"
   echo "$VCOLLECTION:  Test Failed"
   exit 1
fi

stime=`date +%s`
export VIVSTARTTIME=$stime

sleep 5

build_index -C $VCOLLECTION
build_index -C $VCOLLECTION_REMOTE

wait_for_idle -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION_REMOTE

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 3 $SHOST $VCOLLECTION "+++"
basic_query_test 4 $SHOST $VCOLLECTION_REMOTE "++++"

if [ $results -eq 0 ]; then
   cleanup $SHOST $VCOLLECTION $VUSER $VPW
   cleanup $SHOST $VCOLLECTION_REMOTE $VUSER $VPW
fi

source $TEST_ROOT/lib/run_std_results.sh
