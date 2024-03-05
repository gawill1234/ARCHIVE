#!/bin/bash

#####################################################################
#
#   Test description:
#      This test uses the WWII_Navy database.  The expected result
#      is that it simply complete, even if with errors.  The
#      connection timeout and request timeout are both set to 1.
#      The only thing that is guaranteed to run correctly,
#      assuming no failure, is the scheduling thread.
#
#      This test is so quick, I actually expect it to finish
#      even with the low timeouts.
#

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="dbconnector-1"
   DESCRIPTION="oracle simple view crawl and search, low timeout"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION
MAXTIME=120

#
#   Add a case for time limit
#
casecount=1
#crawlerr_old=1
#crawlout_old=1
#oldtotal=`expr $crawlerr_old + $crawlout_old`
oldtotal=360
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
