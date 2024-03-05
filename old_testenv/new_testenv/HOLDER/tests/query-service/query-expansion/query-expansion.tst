#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

#
#   This test submits multiple queries with and without query expansion enabled
#   to ensure that recall increases when QE is on (more results for expanded query)
#
   TNAME="query-expansion"
   VCOLLECTION="samba-stress"
   VONTOLECTION1="ontolection-english-spelling-variations"
   VONTOLECTION2="ontolection-english-general-basic-example"

   DESCRIPTION="This test compares queries with and without automatic expansions. It targets the core query expansion functionality. In addition to samba-stress, it also crawls two ontolections: 
  ontolection-english-spelling-variations and
  ontolection-english-general-basic-example. 
Warning: case 16 will fail if the conceptual search algorithm has changed, and it will change!"
###

export VIVLOWVERSION="7.5"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case() 
{
   cmpdir="query_cmp_files"
   majorversion=`getmajorversion`
   if [ "$majorversion" -lt "8" ]; then
      cmpdir="query_cmp_files_7"
   fi
   echo "########################################"
   echo "Case $1:  $2"
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$2" -n 100000
   url_count_qe -F querywork/rq$1.res > querywork/rq$1.uri
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.uri
   diff $cmpdir/rq$1.cmp querywork/rq$1.uri > querywork/rq$1.diff
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

collection_check()
{

   ccol=$1
   dcr=$2

   echo "query-expansion:  Checking collection $ccol"

   collection_exists -C $ccol
   exst=$?

   if [ $exst -eq 0 ]; then
      #
      #   Check for the existence of the file system on the target
      #

      restore_collection -Z "query-expansion" -C $VCOLLECTION

      #if [ $dcr -eq 1 ]; then
      #   source $TEST_ROOT/lib/run_std_setup.sh
      #else
      #   start_crawl -C $ccol
      #   wait_for_idle -C $ccol
      #fi

      collection_exists -C $ccol
      exst=$?

      if [ $exst -eq 0 ]; then
         echo "query-expansion:  Collection missing: $ccol."
         echo "query-expansion:  Test Failed."
         exit 1
      fi

      #crawl_check $SHOST $ccol
   else
      build_index -C $ccol
      resume_crawl -C $ccol
      wait_for_idle -C $ccol
   fi
}

doembedded_collections()
{
   start_crawl -C $VONTOLECTION1
   wait_for_idle -C $VONTOLECTION1
   #start_crawl -C $VONTOLECTION2
   #wait_for_idle -C $VONTOLECTION2
}

#####################################################################
test_header $TNAME $DESCRIPTION

#origrepo="qe.save.orig.repo"
#backuprepo="query-exp.repo.backup"

#   Check if samba-stress collection exists.  If it does not, run the crawl.
#   If it does, skip this section and move directly to the queries.
#
majorversion=`getmajorversion`
if [ "$majorversion" -lt "7" ]; then
   echo "Test not valid for version older than 7.0"
   exit 0
fi

#delete_file -F $backuprepo
#delete_file -F $origrepo

#####################################################################
# Making sure the permanent collections (ontolections) exist and 
# starting the crawl (it only takes a few seconds)
#

#
#   Get rid of leftovers from other tests.
#
repository_delete -t options -n query-meta

collection_check $VCOLLECTION 1
doembedded_collections

stime=`date +%s`
export VIVSTARTTIME=$stime

#
#   Create a backup of the original repository
#
#backup_repository -S $origrepo

#
#   Update the repository with the item needed for all and
#   create a seperate backup of it.
#
repository_update -F project-options/query-size.xml -N
#backup_repository -S $backuprepo

###########################################################################
casecount=`expr $casecount + 10`

# QE disabled
# 949
run_case 1 theater

# 668
run_case 2 encyclopedia

# QE enabled
repository_update -F project-options/enable-qe.xml -N

# 1292
run_case 3 theater

# 724
run_case 4 encyclopedia

# make all expansions happen automatically, includes basic-OL example
repository_update -F project-options/all-auto-rel.xml -N

# 1651
run_case 5 theater

# 1809
run_case 6 car

# 1425
#work day
#run_case 7 "work%20day"
run_case 7 "work day"

# 1351
run_case 8 chair 

# upload 
#        max-terms-all.xml: max-terms-per-type=-1
#        query-match-type=exact
repository_update -F project-options/max-terms-all-exact.xml -N

# 1782
run_case 9 chair

# 1651
run_case 10 theater

# upload  query-match-type=terms
repository_update -F project-options/max-terms-all-terms.xml -N

# 1809
run_case 11 car

# 1401
#run_case 12 "work%20day"
run_case 12 "work day"

# 119
run_case 13 convertible

# turn inference on
repository_update -F project-options/inference-on.xml -N

# 1575
run_case 14 convertible

# add weights to symmetric-auto
repository_update -F project-options/add-weights.xml -N

# 1809
# ranking changes, but not total num of results
run_case 15 car

if [ "$majorversion" -ge "8" ]; then
   repository_update -F project-options/conceptual-search.xml -N

   # 1846 - this number might change when the CS algorithm changes (and it will), different suggested concepts might be used as expansions
   run_case 16 theater


   # complex queries ##########

   # 1846
   # car WITHIN CONTENT title
   run_case 17 "theater%20WITHIN%20CONTENT%20snippet"

   # should be 0, but there is a bug right now (bug 14140)
   # just uncomment when fixed, cmp files should be good.
   # title:theater
   #run_case 18 "title%3Atheater"

   # 83
   # fuel BEFORE car WITHIN 3 WORDS 
   run_case 19 "fuel%20BEFORE%20car%20WITHIN%203%20WORDS"

   # add spell checker to the project (look at the vars on the admin tool)
   repository_update -F project-options/add-spelling-corrector.xml -N

   # 1846
   run_case 20 theater

   # currently broken, but should be able to work once fixed bug 14044
   # just uncomment when fixed, cmp files should be good.
   # 83
   # fuel BEFORE car WITHIN 3 WORDS
   #run_case 21 "fuel%20BEFORE%20car%20WITHIN%203%20WORDS"
   # 1846
   # car WITHIN CONTENT title
   #run_case 22 "theater%20WITHIN%20CONTENT%20snippet"
fi

# Get rid of all the modified rpository nodes
#restore_repository -S $origrepo
repository_delete -t options -n query-meta

#delete_repository -S $origrepo
#delete_repository -S $backuprepo

export VIVKILLALL="False"
export VIVDELETE="none"

source $TEST_ROOT/lib/run_std_results.sh
