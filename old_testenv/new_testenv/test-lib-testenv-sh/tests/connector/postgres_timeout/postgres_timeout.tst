#!/bin/bash

#####################################################################
#
#   Test description:
#      This test uses Oracle.  The expected result
#      is that it simply complete, even if with errors.  The
#      connection timeout and request timeout are both set to 1.
#      The only thing that is guaranteed to run correctly,
#      assuming no failure, is the scheduling thread.
#
#      This test should complete in the time allowed.  If it does
#      not, the crawl is killed and the test fails.  For the
#      moment, if the test fails with too few errors and many
#      successes, mark it as passing.  This will be automated
#      soon.
#

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="postgres_timeout"
   DESCRIPTION="Loooong Postgresql crawl, low timeout"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION
#
#   A known runtime + 20%
#
MAXTIME=20000

#
#   Case for time limit, error count, completed count
#
casecount=4

#
#   Calculated old error and completed values for the crawler.
#   Done this way because we have no completed runs to generate
#   a good stats file yet.
#
crawlerr_old=36
crawlout_old=700
oldtotal=`expr $crawlerr_old + $crawlout_old`

source $TEST_ROOT/lib/bg_setup.sh

if [ $waitstatus -eq 0 ]; then
   get_collection -C $VCOLLECTION -H $SHOST
   if [ -f $VCOLLECTION.xml.run ]; then
      mv $VCOLLECTION.xml.run querywork/$VCOLLECTION.xml.run
      xslvalue crawlerr_new $TEST_ROOT/utils/xsl/crawl_errors.xsl querywork/$VCOLLECTION.xml.run -1

      xslvalue crawlout_new $TEST_ROOT/utils/xsl/crawl_output.xsl querywork/$VCOLLECTION.xml.run -1

      newtotal=`expr $crawlerr_new + $crawlout_new`

      if [ $oldtotal -ne $newtotal ]; then
         echo "crawl total:  expected $oldtotal, got $newtotal"
         results=`expr $results + 1`
      fi
   fi
else
   results=`expr $results + 1`
fi

if [ $results -ne 0 ]; then
   echo "Check for deadlocks/hangs"
fi

source $TEST_ROOT/lib/run_std_results.sh
