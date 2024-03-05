#!/bin/bash

#####################################################################
#
#   Test description:
#      This test uses office lotus.  The expected result
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

   VCOLLECTION="shpconnector-1"
   DESCRIPTION="Sharepoint simple crawl, low timeout"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION
#
#   A known runtime + 20%
#
MAXTIME=2000

#
#   Case for time limit, error count, completed count
#
casecount=4

oldtotal=78
duptotal=`expr $oldtotal - 1`
duptotal2=`expr $oldtotal + 1`

source $TEST_ROOT/lib/bg_setup.sh

if [ $waitstatus -eq 0 ]; then
   get_collection -C $VCOLLECTION -H $SHOST
   if [ -f $VCOLLECTION.xml.run ]; then
      mv $VCOLLECTION.xml.run querywork/$VCOLLECTION.xml.run
      xslvalue crawlerr_new $TEST_ROOT/utils/xsl/crawl_errors.xsl querywork/$VCOLLECTION.xml.run -1

      xslvalue crawlout_new $TEST_ROOT/utils/xsl/crawl_output.xsl querywork/$VCOLLECTION.xml.run -1

      xslvalue crawldup_new $TEST_ROOT/utils/xsl/crawl_dups.xsl querywork/$VCOLLECTION.xml.run -1

      newtotal=`expr $crawlout_new + $crawlerr_new + $crawldup_new`

      if [ $oldtotal -ne $newtotal ]; then
         if [ $duptotal -ne $newtotal ]; then
            if [ $duptotal2 -ne $newtotal ]; then
               echo "crawl total:  expected $oldtotal, $duptotal2, or $duptotal, got $newtotal"
               results=`expr $results + 1`
            fi
         fi
      fi
   fi
else
   results=`expr $results + 1`
fi

if [ $results -gt 0 ]; then
   echo "Check for possible deadlocks"
fi

source $TEST_ROOT/lib/run_std_results.sh
