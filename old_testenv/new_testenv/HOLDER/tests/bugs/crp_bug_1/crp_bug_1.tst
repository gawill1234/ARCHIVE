
###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crp_bug_1"
   DESCRIPTION="query bug test requested by Chris, for bug 9687"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

basic_query_test 1 $SHOST $VCOLLECTION ""

source $TEST_ROOT/lib/run_std_results.sh
