#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="ontolection-wiki-japanese-spelling"
   DESCRIPTION="default Japanese OntoLection crawl followed by query syntax tests. This should be pretty fast (508 docs)"

###
###

# to disable having the collection using the default converters, otherwise customer converters get overriden
export VIVDEFCONVERT="false"

# this is really meant for 7.0, but building the test befor that's available
export VIVLOWVERSION="6.0"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
   eurlcnt=$3
   ecnturl=$4
   echo "########################################"
   echo "Case $1:  $2"
   x=0

   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$2"

   sort_query_urls -F querywork/rq$1.res > querywork/rq$1.uri

   aurlcnt=`url_count -F querywork/rq$1.res`
   acnturl=`count_urls -F querywork/rq$1.res`
   afcnt=`grep -- "Jwiki-clean.txt" querywork/rq$1.uri | wc -l`
   nfcnt=`grep -v -- "Jwiki-clean.txt" querywork/rq$1.uri | wc -l`

   if [ $eurlcnt -ne $aurlcnt ]; then
      echo "Returned URL count compare file mismatch"
      echo "   Expected:  $eurlcnt"
      echo "   Actual:    $aurlcnt"
      x=`expr $x + 1`
   fi
   if [ $ecnturl -ne $acnturl ]; then
      echo "Returned URL count mismatch"
      echo "   Expected:  $ecnturl"
      echo "   Actual:    $acnturl"
      x=`expr $x + 1`
   fi
   if [ $eurlcnt -ne $aurlcnt ]; then
      echo "Returned Total Results mismatch"
      echo "   Expected:  $eurlcnt"
      echo "   Actual:    $aurlcnt"
      x=`expr $x + 1`
   fi
   if [ $nfcnt -le 0 ]; then
      echo "Returned Files mismatch"
      echo "   Expected:  All to be Jwiki-clean.txt"
      echo "   Actual:    $nfcnt is not Jwiki-clean.txt"
      x=`expr $x + 1`
   fi

   if [ $x -eq 0 ]; then
      echo "Case $1:  Test Passed"
   else
      echo "Case $1:  Test Failed"
   fi
   echo "########################################"
   results=`expr $results + $x`
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION


if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

if [ $majorversion -lt 8 ]; then
   echo "Test Passed due to the fact that the version is less than 8.0"
   exit 0
fi

######################################################################
# This is a permanent collection, so the only thing I need to do is
# start the crawl (it only takes a few seconds)

start_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

collection_exists -C $VCOLLECTION
exst=$?

stime=`date +%s`
export VIVSTARTTIME=$stime

if [ $exst -eq 0 ]; then
   echo "ontolection-japanese:  $VCOLLECTION missing, starting crawl."

   start_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION

   collection_exists -C $VCOLLECTION
   exst=$?

   if [ $exst -eq 0 ]; then
      echo "ontolection-japanese:  Permenant collection missing: $VCOLLECTION."
      echo "ontolection-japanese:  Test Failed."
      exit 1
   fi
fi

crawl_check $SHOST $VCOLLECTION

testcases=`expr $testcases + 3`

run_case 1 "" 939 200

run_case 2 "microsoft" 2 2

run_case 3 "digital" 1 1

export VIVKILLALL="False" 
export VIVDELETE="None"

source $TEST_ROOT/lib/run_std_results.sh
