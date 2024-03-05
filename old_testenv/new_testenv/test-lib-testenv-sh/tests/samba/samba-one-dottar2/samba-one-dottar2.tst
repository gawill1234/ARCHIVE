#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-one-dottar2"
   DESCRIPTION="samba crawl of one tar file containing only .o files"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

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
sz=`get_index_size -C $VCOLLECTION`
if [ $sz -gt 0 ]; then
   basic_query_test 1 $SHOST $VCOLLECTION _dirname
   basic_query_test 2 $SHOST $VCOLLECTION removeleadingspaces_new
fi

source $TEST_ROOT/lib/run_std_results.sh
