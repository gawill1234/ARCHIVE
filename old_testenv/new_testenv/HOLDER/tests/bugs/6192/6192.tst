#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6192"
   VCOLLECTION_REMOTE="6192-remote"
   DESCRIPTION="remote push fails to clean indices directory"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

# Initialize the silly little file that we are going to use

dir=`vivisimo_dir -d collections 2>&1`
remote_indices="$dir"//$VCOLLECTION_REMOTE/indices/
echo 'this is a magic file that should be cleaned after a crawl' > magic-file

# Get the collections blanked and ready for use by us

delete_collection -C $VCOLLECTION_REMOTE
create_collection -C $VCOLLECTION_REMOTE
delete_collection -C $VCOLLECTION
create_collection -C $VCOLLECTION

# Crawl the collection which will push to the remote collection

start_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

# Put the magic file into the indices directory, build a new index which
# will then push to the remote collection which should clean the indices
# directory getting rid of the file.

put_file -F magic-file -D "$remote_indices"
build_index -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

# Check that the file is really gone

rm -f magic-file 2> /dev/null
get_file -F "$remote-indices/"magic-file
cat magic-file
ls -l magic-file
if [ -s magic-file ]; then
    echo "test failed: magic file was not cleaned by the push"
    stop_indexing -C $VCOLLECTION
    stop_indexing -C $VCOLLECTION_REMOTE
    exit 1
fi

cleanup $SHOST $VCOLLECTION $VUSER $VPW
cleanup $SHOST $VCOLLECTION_REMOTE $VUSER $VPW

rm -f magic-file 2> /dev/null
echo "test passed"
exit 0
