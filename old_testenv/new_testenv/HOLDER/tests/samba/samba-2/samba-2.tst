#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-2"
   DESCRIPTION="samba crawl and search of various doc types"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   Do a refresh if there was a collection based timeout
#
x=`do_action -C $VCOLLECTION -A count -F junkfile`
if [ $x -ne 2152 ]; then
   echo "$VCOLLECTION:  Found $x results, expected 2152"
   echo "$VCOLLECTION:  Getting the collection log database"
   do_action -C $VCOLLECTION -A db -D log
   echo "$VCOLLECTION:  Looking for connector timeout errors"
   y=`do_action -C $VCOLLECTION -A dbquery -Q "select xml from errors;" -F log.sqlt | grep -i timeout | wc -l`
   if [ $y -ge 1 ]; then
      results=0
      echo "$VCOLLECTION:  Timeouts found, doing a crawl refresh"
      refresh_crawl -C $VCOLLECTION
      wait_for_idle -C $VCOLLECTION
      crawl_check $SHOST $VCOLLECTION
   fi
fi

casecount=`expr $casecount + 6`

#
#   args are test number, host, collection, query string
#
simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton+Madison" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Linux" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "We+the+people" -T $VCOLLECTION -n 2150
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 2500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
results=`expr $results + $xx`

if [ "$majorversion" -ge "6" ]; then

   xx=`get_index_file_count -C $VCOLLECTION`
   
   if [ $xx -gt 1 ]; then
   
      echo "A MERGE IS BEING DONE, $xx INDEX FILES FOUND."
      echo "FOLLOWING DATA IS MERGE SPEED AND POST MERGE QUERY PERFORMANCE."
      echo "MERGE TIME WILL BE LINE LABELED \"TOTAL USER TIME:\"."
   
      merge_index -C $VCOLLECTION
      wait_for_idle -C $VCOLLECTION -m merge
   
      casecount=`expr $casecount + 6`
   
      #
      #   args are test number, host, collection, query string
      #
      simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton" -T $VCOLLECTION -n 2150
      xx=$?
      if [ $xx -ne 0 ]; then
         echo "test 1: Case Failed"
      else
         echo "test 1: Case Passed"
      fi
      results=`expr $results + $xx`
      
      simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton+Madison" -T $VCOLLECTION -n 2150
      xx=$?
      if [ $xx -ne 0 ]; then
         echo "test 2: Case Failed"
      else
         echo "test 2: Case Passed"
      fi
      results=`expr $results + $xx`
      
      simple_search -H $SHOST -C $VCOLLECTION -Q "Linux" -T $VCOLLECTION -n 2150
      xx=$?
      if [ $xx -ne 0 ]; then
         echo "test 3: Case Failed"
      else
         echo "test 3: Case Passed"
      fi
      results=`expr $results + $xx`
      
      simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150
      xx=$?
      if [ $xx -ne 0 ]; then
         echo "test 4: Case Failed"
      else
         echo "test 4: Case Passed"
      fi
      results=`expr $results + $xx`
      
      simple_search -H $SHOST -C $VCOLLECTION -Q "We+the+people" -T $VCOLLECTION -n 2150
      xx=$?
      if [ $xx -ne 0 ]; then
         echo "test 5: Case Failed"
      else
         echo "test 5: Case Passed"
      fi
      results=`expr $results + $xx`
      
      simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 2250
      xx=$?
      if [ $xx -ne 0 ]; then
         echo "test 6: Case Failed"
      else
         echo "test 6: Case Passed"
      fi
      results=`expr $results + $xx`
   fi
fi
      
source $TEST_ROOT/lib/run_std_results.sh
