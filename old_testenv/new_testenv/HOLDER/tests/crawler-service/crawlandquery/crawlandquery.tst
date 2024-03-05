#!/bin/bash

#####################################################################

###
#   Global stuff
#
#   This creates a collection and then queries the collection while
#   the crawl is still going on.  The index build flush has been
#   adjusted to 2 for the short version and 5 for the long version.
#   The short version crawl around 45 documents.  The long version
#   crawls around 2150 document.
#
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawlandquery"
   DESCRIPTION="Start a crawl and repeatedly query during the crawl"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

export DEFAULTSUBCOLLECTION=live

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

longflag=0
if [ "$1" == "long" ]; then
   longflag=1
fi

if [ $longflag -eq 1 ]; then
   cp $VCOLLECTION.xml.long $VCOLLECTION.xml
   cp $VCOLLECTION.xml.stats.long $VCOLLECTION.xml.stats
else
   cp $VCOLLECTION.xml.short $VCOLLECTION.xml
   cp $VCOLLECTION.xml.stats.short $VCOLLECTION.xml.stats
fi

majorversion=`getmajorversion`

if [ "$majorversion" -lt "6" ]; then
   echo "Test not valid for version older than 6.0"
   exit 0
fi

#
#  source $TEST_ROOT/lib/run_std_setup.sh
#
getsetopts $*
cleanup $SHOST $VCOLLECTION $VUSER $VPW

create_collection -C $VCOLLECTION -H $SHOST
stime=`date +%s`
export VIVSTARTTIME=$stime
start_crawl -C $VCOLLECTION -H $SHOST -U $VUSER -P $VPW

urlcnt=0
qryrslt=`xmlresultfile -t query -q "NoQuErY"`

sleep 5
get_status -C $VCOLLECTION
x=$?

count=1
while [ $x -eq 3 ]; do
   get_status -C $VCOLLECTION
   x=$?
   sleep 2
   sz=`get_index_size -C $VCOLLECTION`
   if [ $sz -gt 0 ]; then
      run_query -C $VCOLLECTION -O querywork/$qryrslt -n 5000
      newcount=`url_count`
      newcount2=`count_urls`
   else
      newcount=0
      newcount2=0
   fi
   echo "$count:"
   echo "     NEW URL COUNT(expected):  $newcount"
   echo "     NEW URL COUNT(actual):    $newcount2"
   echo "     OLD URL COUNT:            $urlcnt"
   #if [ $newcount -ne $newcount2 ]; then
   #   echo "Expected URL count and the actual count differ.  They"
   #   echo "should be the same."
   #   echo "crawlandquery:  Test Failed"
   #   exit 1
   #fi
   if [ $newcount -lt $newcount2 ]; then
      echo "Expected URL count and the actual count differ.  They"
      echo "should be the same."
      echo "crawlandquery:  Test Failed"
      exit 1
   fi
   if [ $newcount -ne $newcount2 ]; then
      echo "WARNING:  Expected URL count and the actual count differ.  They"
      echo "should be the same."
      echo "crawlandquery:  Test not Failed, but look at it."
   fi
   if [ $newcount -lt $urlcnt ]; then
      echo "Fewer URLs than there were before.  Not suppose to be possible"
      echo "crawlandquery:  Test Failed"
      exit 1
   else
      urlcnt=$newcount
   fi
   count=`expr $count + 1`
done

if [ $urlcnt -eq 0 ]; then
   echo "Queries and crawling should be allowed to happen at the"
   echo "same time, but apparently they are not.  No queried"
   echo "URLs were found."
   echo "crawlandquery:  Test Failed"
   exit 1
fi

#
#   Now, wait for all of the remaining indexer stuff
#
wait_for_idle -C $VCOLLECTION

crawl_check_nv $SHOST $VCOLLECTION

if [ $longflag -eq 1 ]; then

   cp query_cmp_files/qry.Hamilton+Madison.xml.cmp.long query_cmp_files/qry.Hamilton+Madison.xml.cmp
   cp query_cmp_files/qry.Hamilton.xml.cmp.long query_cmp_files/qry.Hamilton.xml.cmp
   cp query_cmp_files/qry.Linux.xml.cmp.long query_cmp_files/qry.Linux.xml.cmp
   cp query_cmp_files/qry.Stinkybottom.xml.cmp.long query_cmp_files/qry.Stinkybottom.xml.cmp
   cp query_cmp_files/qry.We+the+people.xml.cmp.long query_cmp_files/qry.We+the+people.xml.cmp
   cp query_cmp_files/qry..xml.cmp.long query_cmp_files/qry..xml.cmp

   casecount=`expr $casecount + 6`
   
   #
   #   args are test number, host, collection, query string
   #
   simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton" -T $VCOLLECTION -n 2150
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test 1: Case Failed"
   else
      echo "test 1: Case Passed"
   fi
   results=`expr $results + $xx`
   
   simple_search -H $SHOST -C $VCOLLECTION -Q "Hamilton+Madison" -T $VCOLLECTION -n 2150
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test 2: Case Failed"
   else
      echo "test 2: Case Passed"
   fi
   results=`expr $results + $xx`
   
   simple_search -H $SHOST -C $VCOLLECTION -Q "Linux" -T $VCOLLECTION -n 2150
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test 3: Case Failed"
   else
      echo "test 3: Case Passed"
   fi
   results=`expr $results + $xx`
   
   simple_search -H $SHOST -C $VCOLLECTION -Q "Stinkybottom" -T $VCOLLECTION -n 2150
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test 4: Case Failed"
   else
      echo "test 4: Case Passed"
   fi
   results=`expr $results + $xx`
   
   simple_search -H $SHOST -C $VCOLLECTION -Q "We+the+people" -T $VCOLLECTION -n 2150
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test 5: Case Failed"
   else
      echo "test 5: Case Passed"
   fi
   results=`expr $results + $xx`
   
   simple_search -H $SHOST -C $VCOLLECTION -Q "" -T $VCOLLECTION -n 2150
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test 6: Case Failed"
   else
      echo "test 6: Case Passed"
   fi
   results=`expr $results + $xx`
else
   cp query_cmp_files/qry.Drahtmüller.xml.cmp.short query_cmp_files/qry.Drahtmüller.xml.cmp
   cp query_cmp_files/qry.Hamilton+Madison.xml.cmp.short query_cmp_files/qry.Hamilton+Madison.xml.cmp
   cp query_cmp_files/qry.Hamilton.xml.cmp.short query_cmp_files/qry.Hamilton.xml.cmp
   cp query_cmp_files/qry.Linux.xml.cmp.short query_cmp_files/qry.Linux.xml.cmp
   cp query_cmp_files/qry.Stinkybottom.xml.cmp.short query_cmp_files/qry.Stinkybottom.xml.cmp
   cp query_cmp_files/qry.We+the+people.xml.cmp.short query_cmp_files/qry.We+the+people.xml.cmp

   basic_query_test 1 $SHOST $VCOLLECTION Hamilton
   basic_query_test 2 $SHOST $VCOLLECTION Hamilton+Madison
   basic_query_test 3 $SHOST $VCOLLECTION Linux
   basic_query_test 4 $SHOST $VCOLLECTION Stinkybottom
   basic_query_test 5 $SHOST $VCOLLECTION We+the+people
   basic_query_test 6 $SHOST $VCOLLECTION Drahtmüller
fi
   
source $TEST_ROOT/lib/run_std_results.sh
