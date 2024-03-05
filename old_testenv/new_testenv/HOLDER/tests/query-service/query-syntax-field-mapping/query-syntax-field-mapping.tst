#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

#
#   This test submits multiple queries to the original samba-stress source as
#   well as modified sources (samba-sress-<n>) in order to test field mappings
#    with: 
#     - one vlaue
#     - multiple values
#     - positive and negative values

#
   TNAME="query-syntax-field-mapping"
   VCOLLECTION="samba-stress"
   VSOURCE="samba-stress"
   DESCRIPTION="This test exercises different field mappings in the source vse-form."
###

# to test on 6.1
#export VIVHOST="testbed4.test.vivisimo.com"
# to test 7.0

export VIVLOWVERSION="7.0"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case() 
{
   echo "########################################"
   echo "Case $1:  $2"
   run_query -S $VSOURCE -O querywork/rq$1.res -Q "$2"
   url_count -F querywork/rq$1.res > querywork/rq$1.uri
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.uri
   diff query_cmp_files/rq$1.cmp querywork/rq$1.uri > querywork/rq$1.diff
   x=$?
   if [ $x -eq 0 ]; then
      echo "Case $1:  Test Passed"
   else
      echo "Case $1:  Test Failed"
   fi
   echo "########################################"
   results=`expr $results + $x`
}

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
#   Check if samba-stress collection exists.  If it does not, run the crawl.
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
      echo "samba-stress: Test Failed"
      exit 1
   fi

   majorversion=`getmajorversion`

   if [ "$majorversion" -lt "6" ]; then
      echo "Test not valid for version older than 6.0"
      exit 0
   fi

   restore_collection -C $VCOLLECTION
   #source $TEST_ROOT/lib/run_std_setup.sh

   #crawl_check $SHOST $VCOLLECTION
else
   build_index -C $VCOLLECTION
   resume_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION
fi

## Doing this from the admin tool, so that I can test everything from there first
## Adding modified sources to the repository temporarily
repository_import -F samba-stress-1.xml.raw
repository_import -F samba-stress-2.xml.raw


stime=`date +%s`
export VIVSTARTTIME=$stime
casecount=`expr $casecount + 10`

#   function basic_query_test
#   args are test number, host, collection, query string

# The first time, need to run basic_query_test to get the xml.cmp files
# what since that takes the collection, how is that going to work when the src has been modified?
#   function basic_query_test
#   args are test number, host, collection, query string

#basic_query_test 100 $SHOST $VCOLLECTION velocity
run_case 1 velocity

# title:velocity
run_case 2 "title%3Avelocity"

run_case 3 implementation

# title:implementation
run_case 4 "title%3Aimplementation" 

# implementation title:-implementation
run_case 5 "implementation%20title%3A-implementation"

# "automated test documentation"
run_case 6 "%22automated%20test%20documentation%22"

#### CHANGING SOURCE #######################################
VSOURCE="samba-stress-1" # adds: query|-snippet (= implementation NOTWITHIN CONTENT snippet)
run_case 7 implementation

# "automated test documentation" and query:"automated test documentation" should be equivalent now
run_case 8 "%22automated%20test%20documentation%22"

#### CHANGING SOURCE #######################################
VSOURCE="samba-stress-2" # adds: query|-title
# "automated test documentation"
run_case 9 "%22automated%20test%20documentation%22"

# Get rid of all the modified sources
repository_delete -t source -n samba-stress-1
repository_delete -t source -n samba-stress-2
#restore_repository

export VIVKILLALL="False"
export VIVDELETE="none"
source $TEST_ROOT/lib/run_std_results.sh
