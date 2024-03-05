#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6197"
   DESCRIPTION="make dispatch report problems"

###
###

export VIVRUNTARGET="linux"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ "$VIVTARGETOS" == "windows" ]; then
   echo "This test does not work on windows"
   echo "6197:  Test Not Applicable"
   exit 1
fi

sql="select count(*) from message_id where value like 'CRAWLER_DISPATCH_%'"

delete_collection -C $VCOLLECTION
create_collection -C $VCOLLECTION

old=`query_db -s "select count(*) from message_id where value like 'CRAWLER_DISPATCH_%'" -c /usr/bin/sqlite3`

echo "OLD MESSAGE COUNT:  $old"

start_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION

new=`query_db -s "select count(*) from message_id where value like 'CRAWLER_DISPATCH_%'" -c /usr/bin/sqlite3`

echo "NEW MESSAGE COUNT:  $new"

#
#  Do it this way so if "if" has syntax error because
#  a variable did not get set right, the test will fail
#  rather than default to pass.
#
if [ "$new" -eq `expr "$old" + 3` ]; then
   echo "test passed: 3 new messages reported"
   if [ "$VIVDELETE" == "" ] || [ "$VIVDELETE" == "all" ] || [ "$VIVDELETE" == "pass" ]; then
      delete_collection -C $VCOLLECTION
   fi
   exit 0
fi

echo "test failed: $old messages pre-run, $new messages post run (should be 3 new ones)"
exit 1
