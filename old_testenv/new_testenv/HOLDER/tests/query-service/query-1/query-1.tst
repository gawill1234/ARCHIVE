#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   TNAME="query-1"
   VCOLLECTION="query-1"
   DESCRIPTION="Refresh with concurrent queries"

###
###

export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

#
#   Check for the existence of the file system on the target
#   Note, this test only works on Linux.
#
fe=`file_exists -F /testenv/CHECKFILE`
if [ $fe -eq 1 ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "$TNAME: Test Failed"
   exit 1
fi

if [ "$TARGETOS" == "windows" ]; then
   cp $VCOLLECTION.xml.windows $VCOLLECTION.xml
else
   cp $VCOLLECTION.xml.notwindows $VCOLLECTION.xml
fi

source $TEST_ROOT/lib/run_std_setup.sh

get_collection -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
mv $VCOLLECTION.xml.run querywork/$VCOLLECTION.xml.run

get_valid_index indexval $VCOLLECTION
if [ -f $VCOLLECTION.xml.$indexval ]; then
   cp $VCOLLECTION.xml.$indexval $VCOLLECTION.xml.stats
   crawl_check $SHOST $VCOLLECTION
else
   echo "No suitable stats file to compare"
   results=`expr $results + 1`
fi

./refresh.sh $VCOLLECTION $SHOST $VUSER $VPW &
rfcmd=$!

./query.sh $VCOLLECTION $SHOST &
qry1=$!

./query.sh $VCOLLECTION $SHOST &
qry2=$!

maxmax=1000
#maxmax=200
iter=1
while [ $iter -le $maxmax ]; do

   echo "Pass $iter of $maxmax"
   if [ -f querywork/$VCOLLECTION.xml.run ]; then
      rm querywork/$VCOLLECTION.xml.run
   fi
   sleep 1

   get_collection -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
   mv $VCOLLECTION.xml.run querywork/$VCOLLECTION.xml.run

   get_status -C $VCOLLECTION
   mystat=$?

   if [ $mystat -eq 0 ]; then
      get_valid_index indexval $VCOLLECTION

      if [ -f $VCOLLECTION.xml.$indexval ]; then
         cp $VCOLLECTION.xml.$indexval $VCOLLECTION.xml.stats
         crawl_check_nv $SHOST $VCOLLECTION refresh noget
      else
         echo "Valid index value is $indexval, expected 34 or 54"
         echo "No suitable stats file to compare"
         results=`expr $results + 1`
      fi
   else
      if [ $mystat -eq 3 ]; then
         echo "Crawler still running"
      elif [ $mystat -eq 2 ]; then
         echo "Indexer still running"
      elif [ $mystat -eq 1 ]; then
         echo "Unknow crawl status"
      else
         echo "Crawler/indexer are idle"
      fi
   fi

   iter=`expr $iter + 1`
done

kill -9 $rfcmd $qry1 $qry2

wait_for_idle -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

if [ -f querywork/$VCOLLECTION.xml.run ]; then
   rm querywork/$VCOLLECTION.xml.run
fi

#
#   Give the test a tolerance.  If five or less of the loops
#   fail, let it pass.  That would be about a .5% tolerance
#   for error.
#
if [ $results -le 5 ]; then
   results = 0
fi


get_collection -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW
mv $VCOLLECTION.xml.run querywork/$VCOLLECTION.xml.run

get_valid_index indexval $VCOLLECTION

echo "Final valid index value:  $indexval"
#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION quick+brown $TARGETOS
basic_query_test 2 $SHOST $VCOLLECTION Alarm $TARGETOS

if [ $indexval -eq 54 ]; then
   basic_query_test 3 $SHOST $VCOLLECTION williams $TARGETOS
   basic_query_test 4 $SHOST $VCOLLECTION suffix_file $TARGETOS
   basic_query_test 5 $SHOST $VCOLLECTION junk3.xls $TARGETOS
fi


#
#   Final checks that the query
#   service is, in fact, working correctly.
#   If the query service is not working, that is reason to fail.
#
query_service_status -H $SHOST
if [ $? -ne 1 ]; then
   echo "Query service indicate down.  Crashed?  Restarting."
   results=`expr $results + 1`
   #
   #   Restart for next test
   #
   start_query_service -H $SHOST -U $VUSER -P $VPW
fi

export VIVERRORREPORT="False"

source $TEST_ROOT/lib/run_std_results.sh
