#!/bin/bash

#####################################################################
#
#   Crawl directories approximately 26+ levels deep.  Tests samba
#   levels as well as non-default crawl hops.
#
#   All told, there are less than 200 documents in this crawl so
#   all matched urls should be in the returned queries.
#

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba_deep"
   DESCRIPTION="samba crawl of very deep directories"

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
basic_query_test 1 $SHOST $VCOLLECTION Meridian
basic_query_test 2 $SHOST $VCOLLECTION McIntosh
basic_query_test 3 $SHOST $VCOLLECTION Adcom
basic_query_test 4 $SHOST $VCOLLECTION Stinkybottom
basic_query_test 5 $SHOST $VCOLLECTION Cary+Audio
basic_query_test 6 $SHOST $VCOLLECTION adcom+mcintosh

source $TEST_ROOT/lib/run_std_results.sh
