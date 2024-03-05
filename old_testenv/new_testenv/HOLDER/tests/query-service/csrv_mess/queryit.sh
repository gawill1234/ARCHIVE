#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="csrv_mess"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
while [ true ]; do
   run_query -C $VCOLLECTION -Q Meridian -O /dev/null
   run_query -C $VCOLLECTION -Q Meridian -O /dev/null
   run_query -C $VCOLLECTION -Q Meridian -O /dev/null
done

exit 0
