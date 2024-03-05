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

   DESCRIPTION="This test compares queries with and without automatic expansions. It targets the core query expansion functionality. In addition to samba-stress, it also crawls an ontolection: ontolection-english-spelling-variations."
###

export VIVLOWVERSION="7.5"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
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

collection_check()
{

   ccol=$1

   echo "query-expansion:  Checking collection $ccol"

   collection_exists -C $ccol
   exst=$?

   if [ $exst -eq 0 ]; then

      source $TEST_ROOT/lib/run_std_setup.sh
      crawl_check $SHOST $ccol

      collection_exists -C $ccol
      exst=$?

      if [ $exst -eq 0 ]; then
         echo "query-expansion:  Collection missing: $ccol."
         echo "query-expansion:  Test Failed."
         exit 1
      fi

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
}

#####################################################################
test_header $TNAME $DESCRIPTION

#   Get rid of leftovers from other tests.
#
repository_delete -t options -n query-meta

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

majorversion=`getmajorversion`

cmpdir="query_cmp_files"
if [ "$majorversion" -lt "8" ]; then
   cmpdir="${cmpdir}_7"
fi

for file in ${cmpdir}/r*
do
   echo "Updating file ${file}"
   sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
   sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

#   Check if samba-stress collection exists.  If it does not,
#   run the crawl (windows).
#   If it does, move directly to the queries.

collection_check $VCOLLECTION

#####################################################################
# Making sure the permanent collections (ontolections) exist and
# starting the crawl (it only takes a few seconds)
#

doembedded_collections

stime=`date +%s`
export VIVSTARTTIME=$stime

#
#   Update the repository with the item needed for all
#
repository_update -F project-options/query-size.xml -N

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
repository_delete -t options -n query-meta

export VIVKILLALL="False"
export VIVDELETE="none"

rm ${VCOLLECTION}.xml
rm ${cmpdir}/r*

source $TEST_ROOT/lib/run_std_results.sh
