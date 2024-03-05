#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6263"
   VCOLLECTION_REMOTE="6263-remote"
   DESCRIPTION="fast refresh (deletes only) + remote push"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

# Get the collections blanked and ready for use by us

delete_collection -C $VCOLLECTION_REMOTE
create_collection -C $VCOLLECTION_REMOTE
delete_collection -C $VCOLLECTION
create_collection -C $VCOLLECTION

# Crawl the collection which will push to the remote collection

stime=`date +%s`
export VIVSTARTTIME=$stime

start_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

# Should have both results

basic_query_test 1 $SHOST $VCOLLECTION "+"
basic_query_test 2 $SHOST $VCOLLECTION_REMOTE ++

# Refresh which should deleted 1 of the 2 results

refresh_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

# And test that it's all right

basic_query_test 3 $SHOST $VCOLLECTION "+++"
basic_query_test 4 $SHOST $VCOLLECTION_REMOTE "++++"

if [ $results -eq 0 ]; then
   cleanup $SHOST $VCOLLECTION $VUSER $VPW
   cleanup $SHOST $VCOLLECTION_REMOTE $VUSER $VPW
else
   stop_indexing -C $VCOLLECTION
   stop_indexing -C $VCOLLECTION_REMOTE
fi

source $TEST_ROOT/lib/run_std_results.sh
