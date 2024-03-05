#!/bin/bash

#####################################################################
#
#   This test accesses a samba share on testbed2.  Within the share
#   restricted_users/samba_test_data/samba-1/doc, the file
#   constitution.pdf is limited access to test\jet user.  The whole
#   share is limited to test\jet and testbed2\fuzzy_lumpkin.
#

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-restricted-1"
   DESCRIPTION="User restricted samba crawl and search of various doc types"

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
basic_query_test 1 $SHOST $VCOLLECTION Hamilton
basic_query_test 2 $SHOST $VCOLLECTION Hamilton+Madison
basic_query_test 3 $SHOST $VCOLLECTION Linux
basic_query_test 4 $SHOST $VCOLLECTION Stinkybottom
basic_query_test 5 $SHOST $VCOLLECTION We+the+people

source $TEST_ROOT/lib/run_std_results.sh
