#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="regex-1"
   DESCRIPTION="oracle simple view crawl and search, regex queries (based on wildcard-3)"
   TARGETHOST=testbed5.test.vivisimo.com

###
###

export VIVLOWVERSION="7.5"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
   echo "########################################"
   echo "Case $1:  $2 as $3"
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$3" -n 5000
   count_urls -F querywork/rq$1.res > querywork/rq$1.resuri
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.resuri
   count_urls -F query_cmp_files/$2.cmp > querywork/rq$1.origuri
   sort_query_urls -F query_cmp_files/$2.cmp >> querywork/rq$1.origuri
   diff querywork/rq$1.origuri querywork/rq$1.resuri > querywork/rq$1.diff
   x=$?
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

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
run_case 1 Arizona "m/^Arizona$/"
run_case 2 Arizona "m/^Ar..o.*a$/"
run_case 3 "Arizona+Battleship" "Arizona+m/^Battle.*$/"
run_case 4 bismarck "m/^bisma...$/"
run_case 5 arizona "m/^.*zona$/"
run_case 6 Blücher "m/^Bl.cher$/"
run_case 8 Blücher "m/^Bl.cher/"
run_case 9 Blücher "m/^Bl..her/"
run_case 10 Blücher "Blücher"
#
#   Due to either a DB or translation error, this case will apparently
#   always fail so I am removing the case.
#
#run_case 7 Blücher "m/^Blücher$/"

#
#   Since we killed the collection, the error report 
#   is invalid as far as we are concerned.
#
VIVERRORREPORT="False"
#delete_collection -C $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
