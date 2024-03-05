#!/bin/bash

#####################################################################

###
#   Global stuff
###
#
#   Test checks that there are multiple (at least 2) query queues.
#   A long query is run, followed a second later by a short query.
#   Then, the short query is waited for first.  If the short query
#   ends up in a single queue or in the same queue as the long query,
#   the wait for the short will take a long time followed by a short
#   wait for the long query(it would have finished while we were waiting
#   for the short query).  This would make the wait for the long really
#   short, thus failing the test.  Did you understand that?
#
   
   source $TEST_ROOT/lib/global_setting.sh

#
#   files-2 as the VCOLLECTION is intentional
#
   TNAME="files-6"
   VCOLLECTION="files-2"
   DESCRIPTION="search queue test, query with many returns vs query with 1"

###
###

export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $TNAME $DESCRIPTION

#
#   Check if files-2 collection exists.  If it does not, run the crawl.
#   If it does, skip this section and move directly to the queries.
#
collection_exists -C $VCOLLECTION
exst=$?

stime=`date +%s`
export VIVSTARTTIME=$stime

if [ ! -z $VIVTARGETARCH ]; then
   if [ "$VIVTARGETARCH" != "linux64" ] && [ "$VIVTARGETARCH" != "linux32" ]; then
      echo "Test fails because it can not be run on target architecture:  $VIVTARGETARCH"
      echo "$TNAME:  Test Failed"
      exit 1
   fi
else
   echo "Unknown target architecture.  Set environment variable"
   echo "VIVTARGETARCH.  Valid values are linux32, linux64,"
   echo "windows32, window64, solaris32 or solaris64."
   echo "However, this test only works with linux64 and linux32."
   echo "$TNAME:  Test Failed"
   exit 1
fi

if [ $exst -eq 0 ]; then
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
      echo "$TNAME: Test Failed"
      exit 1
   fi

   majorversion=`getmajorversion`

   if [ "$majorversion" -lt "6" ]; then
      echo "Test not valid for version older than 6.0"
      exit 0
   fi

   source $TEST_ROOT/lib/run_std_setup.sh

   crawl_check $SHOST $VCOLLECTION
fi

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#   args are test number, host, collection, query string
#
casecount=`expr $casecount + 1`

echo "Starting long query"
run_query -C $VCOLLECTION -Q "Plaintiff" -O querywork/pllong.result -n 30000 -N &
xx=$!

#
#   This sleep should not have any effect on the result since the long
#   return should take so much longer than the short.  It will, however,
#   make sure the long query is enqueued first.
#
sleep 2

echo "Starting short query"
run_query -C $VCOLLECTION -Q "Plaintiff" -O querywork/plshort.result -n 1 -N &
yy=$!

#
#   Wait for the short query
#
echo "wait for short query"
starty=`date +%s`
wait $yy
wy=`date +%s`
echo "short wait complete"

#
#   Wait for the long query
#
echo "wait for long query"
startx=`date +%s`
wait $xx
wx=`date +%s`
echo "long wait complete"

tx=`expr $wx - $startx`
ty=`expr $wy - $starty`

echo "$TNAME:  Small returns time = $ty"
echo "$TNAME:  Large returns time = $tx"
if [ $ty -ge $tx ]; then
   results=`expr $results + 1`
   echo "$TNAME:  search queue test failed"
else
   echo "$TNAME:  search queue test passed"
fi

# When files-# run as a group, they leave the collection files-2 to
# the next test. However, at the moment files-6 is the only test that 
# runs, so deleting the collection on pass is more practical.
#export VIVDELETE="none"
export VIVDELETE="pass"
source $TEST_ROOT/lib/run_std_results.sh
