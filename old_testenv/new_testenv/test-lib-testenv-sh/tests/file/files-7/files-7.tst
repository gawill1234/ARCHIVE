#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

#
#   files-2 as the VCOLLECTION is intentional
#   This test depends on the files-2 collection.
#   This test takes so long to run that any chunk of failure
#   is grounds to stop that query and move on.
#
   TNAME="files-7"
   VCOLLECTION="files-2"
   DESCRIPTION="search of many(700K) html docs with large returns"

###
###

export VIVLOWVERSION="6.1"
export VIVRUNTARGET="linux solaris"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

do_query_stuff()
{

   echo "############## Begin #########################"
   xx=0
   echo "  query $1:  Query -- $2"
   echo "  query $1:  expecting $3 items returned"
   echo "  query $1:  expecting $4 as total results"
   OUTFILE="querywork/qry.$2.xml.rslt"
   CMPFILE="query_cmp_files/qry.$2.uri.cmp"

   if [ ! -f $CMPFILE ]; then
      echo "query $1:  $CMPFILE (known data) does not exist - Failed"
      xx=1
   fi

   if [ $xx -eq 0 ]; then
      run_query -H $SHOST -C $VCOLLECTION -Q "$2" -n $3 -O $OUTFILE
      xx=$?
      if [ ! -f $OUTFILE ]; then
         echo "  query $1:  $OUTFILE (test data) does not exist - Failed"
         xx=1
      fi
   fi

   if [ $xx -ne 0 ]; then
      echo "  query $1: Query Failed"
   else
      echo "  query $1: Query Passed"
      alldocs=`url_countP -F $OUTFILE`
      if [ $alldocs -ne $4 ]; then
         echo "  query $1:  Count A Failed, expected $4, got $alldocs"
         xx=1
      else
         echo "  query $1:  Count A Passed, expected $4, got $alldocs"
         recvdocs=`count_urlsP -F $OUTFILE`
         if [ $recvdocs -ne $3 ]; then
            echo "  query $1:  Count B Failed, expected $3, got $recvdocs"
            xx=1
         else
            echo "  query $1:  Count B Passed, expected $3, got $recvdocs"
            url_existence_check -F $CMPFILE -R $OUTFILE -T url
            xx=$?
            if [ $xx -ne 0 ]; then
               echo "  query $1:  Test Failed"
            else
               echo "  query $1:  Test Passed"
            fi
         fi
      fi
   fi
   results=`expr $results + $xx`
   echo "############## End ###########################"
}

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
      echo "files-4: Test Failed"
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

do_query_stuff 1 2001 31304 31304
do_query_stuff 2 1872 4252 4252
do_query_stuff 3 "UNITED+STATES+COURT+OF+APPEALS" 20000 674070
do_query_stuff 4 violation 10000 206252
do_query_stuff 5 appeal 11101 676643
do_query_stuff 6 Plaintiff 100000 295103

export VIVDELETE="none"
source $TEST_ROOT/lib/run_std_results.sh
