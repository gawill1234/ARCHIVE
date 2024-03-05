#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="live-start"
   DESCRIPTION="New collections start in live.  Uses oracle crawl"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

runcnt=0

while [ $runcnt -lt 10 ]; do
   echo "----   TEST PASS:  $runcnt   ------------------"
   echo "####   DELETE COLLECTION   ####"
   delete_collection -C $VCOLLECTION
   echo "####   CREATE COLLECTION   ####"
   create_collection -C $VCOLLECTION
   echo "####   START CRAWL   ####"
   start_crawl -C $VCOLLECTION
   echo "####   GET COLLECTION   ####"
   get_admin_xml -C $VCOLLECTION
   echo "####   LOOK FOR STAGING DATA   ####"
   xxx=`xsltproc --stringparam mynode staging-run $TEST_ROOT/utils/xsl/parse_admin_60.xsl querywork/$VCOLLECTION.admin.xml`
   echo "   Got staging pid for:  $xxx"
   if [ "$xxx" != "Nothing" ]; then
      echo "live-start:  Found a staging node and should not have"
      echo "             Look in file querywork/$VCOLLECTION.staging.found"
      cp querywork/$VCOLLECTION.admin.xml querywork/$VCOLLECTION.staging.found
      results=`expr $results + 1`
      runcnt=99
      echo "####   WAIT FOR IDLE AND CHECK CRAWL STATS   ####"
      wait_for_idle -C $VCOLLECTION
      crawl_check $SHOST $VCOLLECTION
   else
      echo "####   WAIT FOR IDLE AND CHECK CRAWL STATS   ####"
      wait_for_idle -C $VCOLLECTION
      crawl_check $SHOST $VCOLLECTION
      if [ $results -gt 0 ]; then
         runcnt=99
      else
         runcnt=`expr $runcnt + 1`
      fi
   fi
done

source $TEST_ROOT/lib/run_std_results.sh
