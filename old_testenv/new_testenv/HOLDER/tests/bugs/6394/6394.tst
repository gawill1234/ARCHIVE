#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6394"
   DESCRIPTION="don't merge regex parser contents that have different attributes"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh
crawl_check $SHOST $VCOLLECTION norefresh get strict

source $TEST_ROOT/lib/run_std_results.sh
