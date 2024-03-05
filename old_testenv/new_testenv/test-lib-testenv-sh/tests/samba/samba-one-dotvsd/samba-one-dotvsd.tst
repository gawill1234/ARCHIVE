#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="samba-one-dotvsd"
   DESCRIPTION="samba crawl of one visio file"

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

source $TEST_ROOT/lib/run_std_results.sh
