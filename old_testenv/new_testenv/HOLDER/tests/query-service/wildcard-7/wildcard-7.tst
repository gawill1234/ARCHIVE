#!/bin/bash

#####################################################################

###
#   Global stuff
#
#   This test creates a collection and starts a crawl.
#   After the crawl is started, it periodically kills the
#   indexer.  The indexer should recover and complete
#   normally.  It kills the indexer 100 times, then
#   waits for the remainder of the crawl to finish.
#   After the crawl completes, we save a copy of the wildcard
#   dictionary and then remove it and restart the indexer service.
#   The service should reconstruct the dictionary and when it is
#   idle we verify that the reconstructed dictionary is the same.
#
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="wildcard-7"
   DESCRIPTION="Crawl and query collection while killing indexer"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="indexer"
export VIVLOWVERSION="7.5"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

cleanup_processes()
{
    echo "Killing query processes:"
    kill -9 $pid1 $pid2 $pid3
}

exit_error()
{
    cleanup_processes
    exit 1
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#MAXITER=100
MAXITER=75
hangon=0

#  source $TEST_ROOT/lib/run_std_setup.sh
#
getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW
setup_no_wait $SHOST $VCOLLECTION $VUSER $VPW

# Wait for awhile to make sure we get all the directories started
sleep 30
get_status -C $VCOLLECTION
x=$?

echo "Start the query.sh processes"
./query.sh 1 $VCOLLECTION &
pid1=$!
./query.sh 2 $VCOLLECTION &
pid2=$!
./query.sh 3 $VCOLLECTION &
pid3=$!

echo "Enter the kill indexer loop"
count=1
while [ $x -eq 3 ]; do
   echo "Iteration:  $count"
   echo "Current status value:  $x"
   sleepval=`genrand -M 15 -m 5`
   echo "Kill indexer and then wait $sleepval seconds"
   kill_service_children -C $VCOLLECTION -S indexer
   sleep $sleepval
   get_status -C $VCOLLECTION
   x=$?
   zz=`hang_check -C $VCOLLECTION`
   if [ $zz -gt 0 ]; then
      hangon=`expr $hangon + 1`
   else
      hangon=0
   fi
   if [ $hangon -gt 3 ]; then
      echo "$VCOLLECTION:  Crawler/Indexer hung"
      echo "$VCOLLECTION:  Test Failed"
      exit_error
   fi
   if [ $count -ge $MAXITER ]; then
      break
   fi
   count=`expr $count + 1`
done

#
#   Kill the query processes before trying to do anything
#   because they will restart the indexer!
#

echo "Check that the query.sh processes survived"
if ! ps -p $pid1 ; then
   echo "One of the query workers failed."
   exit_error
fi

if ! ps -p $pid2 ; then
   echo "One of the query workers failed."
   exit_error
fi

if ! ps -p $pid3 ; then
   echo "One of the query workers failed."
   exit_error
fi

echo "Kill the query.sh processes"
cleanup_processes

#
#   Now, wait for all of the remaining indexer stuff
#
wait_for_idle -C $VCOLLECTION
wfistat=$?
if [ $wfistat -eq 2 ]; then
   echo "$VCOLLECTION:  Crawler/Indexer hung"
   echo "$VCOLLECTION:  Test Failed"
   exit_error
fi

#
#   Check the final search results to make sure we are
#   getting the expected counts
#

echo "check final searches"
if ! ./query.sh 1 $VCOLLECTION --final ; then
   echo "Final searches are wrong."
   exit_error
fi

crawl_check_nv $SHOST $VCOLLECTION

echo "Kill the indexer"
kill_service_children -C $VCOLLECTION -S indexer

#
#   Grab a copy of the dictionary and then nuke it
#

path=`get_crawl_dir -C $VCOLLECTION`

full_md5_name=`xsltproc --stringparam mynode wcdict-name $TEST_ROOT/utils/xsl/parse_admin_60.xsl querywork/$VCOLLECTION.admin.xml`

md5_name=`basename $full_md5_name`

echo "MD5 name is $md5_name"
full_dict="$path"/wc/$md5_name

echo "Get file $full_dict"

get_file -F "$full_dict"
if [ ! -r $md5_name ]; then
    echo Failed to get the wildcard dictionary from the collection.
    exit_error
fi
mv $md5_name querywork/dictionary1.raw
#normalize_dictionary.sh < querywork/dictionary1.raw > querywork/dictionary1.sorted

echo "Normalize the first dictionary"
normalize_dictionary.sh -I querywork/dictionary1.raw -O querywork/dictionary1.sorted

echo "Delete the first dictionary"
delete_file -F "$full_dict"
delete_file -F "$full_dict".xml

#
# Resume the indexer and then let it reconstruct
# the dictionary.
#

echo "Start the indexer to rebuild the dictionary"
build_index -C $VCOLLECTION
sleep 2
wait_for_idle -C $VCOLLECTION

#
#   Check the final search results to make sure we are
#   getting the expected counts
#

echo "Check final searches again"
if ! ./query.sh 1 $VCOLLECTION --final ; then
   echo "Final searches are wrong."
   exit_error
fi

#
#   Get the dictionary that was reconstructed
#

kill_service_children -C $VCOLLECTION -S indexer

echo "Get file $full_dict again"
get_file -F "$full_dict"
if [ ! -r $md5_name ]; then
    echo Failed to get the wildcard dictionary from the collection.
    exit_error
fi

mv $md5_name querywork/dictionary2.raw
#normalize_dictionary.sh < querywork/dictionary2.raw > querywork/dictionary2.sorted
echo "Normalize the second dictionary"
normalize_dictionary.sh -I querywork/dictionary2.raw -O querywork/dictionary2.sorted

#
# Test that both dictionaries are the same and that they are
# also the same as the correct dictionary.
#

echo "Testing that the two dictionaries are the same"
if ! diff querywork/dictionary1.sorted querywork/dictionary2.sorted ; then
    echo "Case failed"
    exit_error
fi

echo "Testing that the two dictionaries are correct"
if ! diff query_cmp_files/dictionary.sorted querywork/dictionary1.sorted ; then
    echo "Case failed"
    exit_error
fi

source $TEST_ROOT/lib/run_std_results.sh
