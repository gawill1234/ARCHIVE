#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="large_random_data-2"
   DESCRIPTION="file system crawl of large, changing data set"

###
###

export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################
test_header $VCOLLECTION $DESCRIPTION

RUNFOR=86400
#RUNFOR=3600
SLEEPFOR=300
DATATARGET="/testenv/lrd/test2"
casecount=0
results=0

if [ -f /testenv/CHECKFILE ]; then
   echo "/testenv is mounted locally.  We can continue"
else
   echo "/testenv directory is not mounted locally."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "refresh-stress: Test Failed"
   exit 1
fi

fe=`file_exists -F /testenv/CHECKFILE`
if [ $fe -eq 1 ]; then
   echo "/testenv is mounted on target.  We can continue"
else
   echo "/testenv directory is not mounted on target."
   echo "Create a target machine directory named /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "on the target machine."
   echo "Then rerun the test"
   echo "files-2: Test Failed"
   exit 1
fi

getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW

rm -rf -- $DATATARGET

lrd_create -F $DATATARGET -f 40 -c f -r $RUNFOR &

sleep $SLEEPFOR

create_collection -C $VCOLLECTION -H $SHOST

stime=`date +%s`
runtime=`expr $stime + $RUNFOR`
export VIVSTARTTIME=$stime

start_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
wait_for_idle -C $VCOLLECTION

while [ 1 ]; do
   refresh_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION
   stime=`date +%s`
   if [ $stime -ge $runtime ]; then
      break
   fi
done

refresh_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

ndocs=`valid_indexes -C $VCOLLECTION`
totvals=`expr $ndocs + 10000`

#
#   Put this in so you can clearly see the progress of the
#   data through this part of the test.
#
FIRSTFILE="querywork/qrydump"
SECONDFILE="querywork/qryurldump"
THIRDFILE="querywork/qryurlfixed"

#
#   Null query, creates first file.
#
run_query -C $VCOLLECTION -Q "" -O $FIRSTFILE -n $totvals -N

#
#   Extract only the urls from the query file
#
get_query_urls -F $FIRSTFILE > $SECONDFILE

#
#   Decode any url encoded stuff
#
dus -I $SECONDFILE -O $THIRDFILE

qret=`wc -l $THIRDFILE | cut -d ' ' -f 1`

#
#   Basic check against itself.  Make sure we got back
#   the number of documents that have been indexed.
#
casecount=`expr $casecount + 1`
if [ $qret -ne $ndocs ]; then
   echo "Returned docs and indexed docs disagree"
   results=`expr $results + 1`
else
   echo "Returned docs and indexed docs agree"
fi
echo "Returned:  $qret,  Indexed:  $ndocs"

#
#   Make sure the returned urls/files actually exist.
#   If not, the final refresh should have removed them
#   from the index data.
#
REPLACEIT='file://testenv'
REPLACEWITH='/testenv'

qry_node_check -I $THIRDFILE -o $REPLACEIT -n $REPLACEWITH
neres=$?

casecount=`expr $casecount + 1`
if [ $neres -ne 0 ]; then
   echo "Returned docs do not exist."
   results=`expr $results + 1`
else
   echo "Returned docs exist."
fi

#
#   Compare to what we think should have happened based 
#   on the lrd_create output.
#
echo "Section in progress"

#
#   Done
#
source $TEST_ROOT/lib/run_std_results.sh
