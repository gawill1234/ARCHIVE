#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="CNN"
   DESCRIPTION="wildcard search of federated source"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
   echo "########################################"
   echo "Case $1:  $2 as $3"
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$3" -n 5000
   urlcnt=`count_urls -F querywork/rq$1.res`
   if [ $urlcnt -ge 1 ]; then
      echo "Case $1:  Test Passed"
      echo "Found $urlcnt results"
   else
      echo "Case $1:  Test Failed"
      echo "Found $urlcnt results"
      results=`expr $results + 1`
   fi
   echo "########################################"
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

repository_update -F wc_options -N

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
run_case 1 Afghanistan Afghanistan
run_case 2 Afghanistan "Afghan*tan*"
run_case 3 Afghanistan "Afghan*tan"
run_case 4 Afghanistan "Afghanistan*"
run_case 5 afghanistannurestan "afghan*tannurestan"

#
#   Since we messed with the repository, we need
#   to delete the collection so we can put the repository
#   back the way it was.
#
#   Also, since we killed the collection, the error report 
#   is no invalid as far as we are concerned.
#
VIVERRORREPORT="False"

repository_delete -t options -n query-meta

if [ $results -eq 0 ]; then
   echo "wildcard-fedsrc:  Test Passed"
else
   echo "wildcard-fedsrc:  Test Failed"
fi

exit $results



