#!/bin/bash

#####################################################################

###
#   Global stuff
###
#
#   This test does a no-follow crawl of 4 url's.  What it
#   should find is that the number of documents indexed
#   matches the number of urls crawled.
#
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="no-follow-2"
   DESCRIPTION="Crawl of URLs with no-follow set"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

source $TEST_ROOT/lib/run_std_results.sh
