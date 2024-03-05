#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

#
#   files-2 as the VCOLLECTION is intentional
#
   TNAME="files-5"
   VCOLLECTION="files-2"
   DESCRIPTION="search of many(700K) html docs with modest returns"

###
###

export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $TNAME $DESCRIPTION

#
#   Check if files-2 collection exists.  If it does not, run the crawl.
#   If it does, skip this section and move directly to the queries.
#
collection_exists -C $VCOLLECTION
exst=$?

if [ $exst -eq 0 ]; then
   #
   #   Check for the existence of the file system on the target
   #
   fe=`file_exists -F /testenv/CHECKFILE`
   if [ $fe -eq 1 ]; then
      echo "/testenv is mounted.  We can continue"
   else
      echo "/testenv directory is not mounted."
      echo "Create a local directory name /testenv.  Then, as root, do:"
      echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
      echo "Then rerun the test"
      echo "files-5: Test Failed"
      exit 1
   fi

   majorversion=`getmajorversion`

   if [ "$majorversion" -lt "6" ]; then
      echo "Test not valid for version older than 6.0"
      exit 0
   fi

   source $TEST_ROOT/lib/run_std_setup.sh

   crawl_check $SHOST $VCOLLECTION
fi

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
#   args are test number, host, collection, query string
#
casecount=`expr $casecount + 6`
simple_search -H $SHOST -C $VCOLLECTION -Q "Plaintiff" -T $TNAME -n 10000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 1: Case Failed"
else
   echo "test 1: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "2001" -T $TNAME -n 10000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 2: Case Failed"
else
   echo "test 2: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "1872" -T $TNAME -n 10000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 3: Case Failed"
else
   echo "test 3: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "UNITED+STATES+COURT+OF+APPEALS" -T $TNAME -n 10000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 4: Case Failed"
else
   echo "test 4: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "violation" -T $TNAME -n 10000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 5: Case Failed"
else
   echo "test 5: Case Passed"
fi
results=`expr $results + $xx`

simple_search -H $SHOST -C $VCOLLECTION -Q "appeal" -T $TNAME -n 10000
xx=$?
if [ $xx -ne 0 ]; then
   echo "test 6: Case Failed"
else
   echo "test 6: Case Passed"
fi
results=`expr $results + $xx`

export VIVDELETE="none"
source $TEST_ROOT/lib/run_std_results.sh
