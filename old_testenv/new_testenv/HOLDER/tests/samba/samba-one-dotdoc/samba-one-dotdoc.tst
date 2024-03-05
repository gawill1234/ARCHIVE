#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-one-dotdoc"
   DESCRIPTION="samba crawl of one doc file"

###
###

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
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Share
basic_query_test 2 $SHOST $VCOLLECTION content

source $TEST_ROOT/lib/run_std_results.sh