#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="windows-local-group"
   DESCRIPTION="simple crawl to make sure local groups on local files get expanded correctly."

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

# Dump the index, then grep it for appropriate ACLs

dump_index -C $VCOLLECTION

# one more case we are testing
casecount=`expr $casecount + 1`

if [ -f $VCOLLECTION.index ]; then
    mv $VCOLLECTION.index querywork/$VCOLLECTION.index
    fgrep 'content' querywork/$VCOLLECTION.index | fgrep 'acl' > querywork/$VCOLLECTION.index.snippet

    diff query_cmp_files/$VCOLLECTION.index.snippet querywork/$VCOLLECTION.index.snippet > querywork/index.snippet.diff
    difx=$?
    
    if [ $difx -ne 0 ]; then
	echo "   ACL indices differ"
	results=`expr $results + 1`
    fi    
else
    results=`expr $results + 1`
fi

source $TEST_ROOT/lib/run_std_results.sh
