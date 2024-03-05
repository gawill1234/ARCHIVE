#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="wildcard-3"
   DESCRIPTION="oracle simple view crawl and search, wildcard queries"
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
   count_urls -F query_cmp_files/qry.$2.xml.cmp > querywork/rq$1.origuri
   sort_query_urls -F query_cmp_files/qry.$2.xml.cmp >> querywork/rq$1.origuri
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
run_case 1 Arizona Arizona
run_case 2 Arizona "Ar*o*a"
run_case 3 "Arizona+Battleship" "Arizona Battle*"
run_case 4 bismarck "bisma*"
run_case 5 arizona "*zona"
run_case 6 Blücher "Bl*cher"

#
#   Since we messed with the repository, we need
#   to delete the collection so we can put the repository
#   back the way it was.
#
#   Also, since we killed the collection, the error report 
#   is no invalid as far as we are concerned.
#
VIVERRORREPORT="False"
delete_collection -C $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
