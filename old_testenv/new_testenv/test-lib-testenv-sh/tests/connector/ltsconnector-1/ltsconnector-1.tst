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

   VCOLLECTION="ltsconnector-1"
   DESCRIPTION="lotus simple crawl, low timeout"
   TARGETHOST=192.168.0.37

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

vdir=`vivisimo_dir -d tmp 2>&1`
echo "LOTUS JAR DIRECTORY"
if [ "$TARGETOS" == "windows" ]; then
   vdir=`echo $vdir | sed 's;\\\\;\\\\\\\\;g'`
fi
echo $vdir

x="sed -e 's;REPLACE__ME;$vdir;g'"

cat basexml | eval $x > ltsconnector-1.xml

put_file -F ./support_software/NCSO.jar -D $vdir
put_file -F ./support_software/Notes.jar -D $vdir

if [ "$TARGETOS" == "windows" ]; then
   fulldir1="$vdir\\NCSO.jar"
   fulldir2="$vdir\\Notes.jar"
else
   fulldir1="$vdir/NCSO.jar"
   fulldir2="$vdir/Notes.jar"
fi

#
#   A known runtime + 20%
#
MAXTIME=10000

#
#   Case for time limit, error count, completed count
#
casecount=4

source $TEST_ROOT/lib/bg_setup.sh

if [ $waitstatus -eq 0 ]; then
   sleep 3
   get_collection -C $VCOLLECTION -H $SHOST
   if [ -f $VCOLLECTION.xml.run ]; then
      mv $VCOLLECTION.xml.run querywork/$VCOLLECTION.xml.run
      xslvalue crawlerr_new $TEST_ROOT/utils/xsl/crawl_errors.xsl querywork/$VCOLLECTION.xml.run -1
      xslvalue crawlerr_old $TEST_ROOT/utils/xsl/crawl_errors.xsl $VCOLLECTION.xml.stats -4

      xslvalue crawlout_new $TEST_ROOT/utils/xsl/crawl_output.xsl querywork/$VCOLLECTION.xml.run -1
      xslvalue crawlout_old $TEST_ROOT/utils/xsl/crawl_output.xsl $VCOLLECTION.xml.stats -4

      oldtotal=`expr $crawlout_old + $crawlerr_old`
      newtotal=`expr $crawlout_new + $crawlerr_new`

      if [ $oldtotal -ne $newtotal ]; then
         echo "crawl total:  expected $oldtotal, got $newtotal"
         results=`expr $results + 1`
      fi
   fi
else
   results=`expr $results + 1`
fi

if [ $results -gt 0 ]; then
   echo "Check for possible deadlocks"
else
   delete_file -F $fulldir1
   delete_file -F $fulldir2
fi

source $TEST_ROOT/lib/run_std_results.sh
