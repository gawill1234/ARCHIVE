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

   VCOLLECTION="smbconnector-1"
   DESCRIPTION="Samba/SMB simple crawl, low timeout"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION
#
#   A known runtime + 20%
#
MAXTIME=5000

if [ "$VIVTARGETOS" == "solaris" ]; then
   echo "smbconnector-1:  Test Passed"
   exit 0
fi

#
#   Case for time limit, error count, completed count
#
casecount=4


majorversion=`getmajorversion`

if [ "$majorversion" -lt "7" ]; then
   crawlout_old=0
else
   crawlout_old=1
fi

if [ "$majorversion" -le "5" ]; then
   crawlerr_old=2159
else
   #
   #   Account for changes in counting in 6.0.
   #
   crawlerr_old=2161
fi

oldtotal=`expr $crawlout_old + $crawlerr_old`
duptotal=`expr $oldtotal - 1`

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
            echo "crawl total:  expected $oldtotal or $duptotal, got $newtotal"
            results=`expr $results + 1`
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
