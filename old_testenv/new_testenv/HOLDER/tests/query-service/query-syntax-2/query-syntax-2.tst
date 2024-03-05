#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="query-syntax-2"
   DESCRIPTION="samba crawl followed by query syntax tests"

###
###

export VIVDEFCONVERT="true"
export VIVLOWVERSION="6.1"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
   echo "########################################"
   echo "Case $1:  $2"
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$2"
   url_count -F querywork/rq$1.res > querywork/rq$1.uri
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.uri
   diff query_cmp_files/rq$1.cmp querywork/rq$1.uri > querywork/rq$1.diff
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

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

majorversion=`getmajorversion`

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

testcases=`expr $testcases + 4`
#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#  (hazard THRU emolument) WITHIN 7 WORDS
#
run_case 1 "%28hazard%20THRU%20emolument%29%20WITHIN%207%20WORDS"

#
#  (hazard THRU emolument)
#
run_case 2 "%28hazard%20THRU%20emolument%29"

#
#  (hazard THRU emolument) WITHIN 2 WORDS
#
run_case 3 "%28hazard%20THRU%20emolument%29%20WITHIN%202%20WORDS"

#
#  (NOT (hazard THRU emolument))
#
run_case 4 "%28NOT%20%28hazard%20THRU%20emolument%29%29"

source $TEST_ROOT/lib/run_std_results.sh
