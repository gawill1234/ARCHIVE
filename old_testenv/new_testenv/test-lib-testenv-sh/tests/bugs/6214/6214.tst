#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6214"
   VCOLLECTION_REMOTE="6214-remote"
   DESCRIPTION="fast refresh + remote push / 2 remote pushes both work"

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

# This should include everything except /etc/passwd

#
#basic_query_test 1 $SHOST $VCOLLECTION "+"
#
simple_search -H $SHOST -C $VCOLLECTION -Q "+" -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 2 $SHOST $VCOLLECTION_REMOTE ++
#
simple_search -H $SHOST -C $VCOLLECTION_REMOTE -Q ++ -T $VCOLLECTION_REMOTE -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 3 $SHOST $VCOLLECTION uk+
#
simple_search -H $SHOST -C $VCOLLECTION -Q uk+ -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 4 $SHOST $VCOLLECTION_REMOTE uk++
#
simple_search -H $SHOST -C $VCOLLECTION_REMOTE -Q uk++ -T $VCOLLECTION_REMOTE -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 5 $SHOST $VCOLLECTION apollo+
#
simple_search -H $SHOST -C $VCOLLECTION -Q apollo+ -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 6 $SHOST $VCOLLECTION_REMOTE apollo++
#
simple_search -H $SHOST -C $VCOLLECTION_REMOTE -Q apollo++ -T $VCOLLECTION_REMOTE -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

# Now do the refresh so that we pick up /etc/passwd

refresh_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

# And test that it's all right

#
#basic_query_test 7 $SHOST $VCOLLECTION "+++"
#
simple_search -H $SHOST -C $VCOLLECTION -Q "+++" -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 7: Case Failed"
else
   echo "test 7: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 8 $SHOST $VCOLLECTION_REMOTE "++++"
#
simple_search -H $SHOST -C $VCOLLECTION_REMOTE -Q "++++" -T $VCOLLECTION_REMOTE -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 8: Case Failed"
else
   echo "test 8: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 9 $SHOST $VCOLLECTION uk+++
#
simple_search -H $SHOST -C $VCOLLECTION -Q uk+++ -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 9: Case Failed"
else
   echo "test 9: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 10 $SHOST $VCOLLECTION_REMOTE uk"++++"
#
simple_search -H $SHOST -C $VCOLLECTION_REMOTE -Q uk"++++" -T $VCOLLECTION_REMOTE -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 10: Case Failed"
else
   echo "test 10: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 11 $SHOST $VCOLLECTION apollo+++
#
simple_search -H $SHOST -C $VCOLLECTION -Q "apollo+++" -T $VCOLLECTION -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 11: Case Failed"
else
   echo "test 11: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

#
#basic_query_test 12 $SHOST $VCOLLECTION_REMOTE apollo"++++"
#
simple_search -H $SHOST -C $VCOLLECTION_REMOTE -Q apollo"++++" -T $VCOLLECTION_REMOTE -n 500
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 12: Case Failed"
else
   echo "test 12: Case Passed"
fi
results=`expr $results + $xx`
casecount=`expr $casecount + 1`

if [ $results -eq 0 ]; then
   cleanup $SHOST $VCOLLECTION $VUSER $VPW
   cleanup $SHOST $VCOLLECTION_REMOTE $VUSER $VPW
else
   stop_indexing -C $VCOLLECTION
   stop_indexing -C $VCOLLECTION_REMOTE
fi

source $TEST_ROOT/lib/run_std_results.sh
