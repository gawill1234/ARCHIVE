#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-1"
   DESCRIPTION="samba crawl and search of various doc types"

###
###

export VIVDEFCONVERT="true"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

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
if [ $x -ne 47 ]; then
   echo "$VCOLLECTION:  Found $x results, expected 47"
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
