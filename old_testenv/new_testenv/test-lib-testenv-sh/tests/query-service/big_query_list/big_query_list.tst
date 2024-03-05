#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="big_query_list"
   DESCRIPTION="samba crawl and search of various doc types, wildcarded search"

###
###

export VIVDEFCONVERT="true"
export VIVLOWVERSION="7.5"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#
#   The origcount/rescount stuff is a kludgy way to deal
#   with duplicates until I find a better way to process
#   query results that may vary because of duplicates.
#
run_case()
{
   echo "########################################"
   echo "Case $1:  $2 as $3"

   origcount=$4
   returnedurls=$5

   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$3" -n 100 -g 0

   rescount=`count_urls -F querywork/rq$1.res`
   expres=`url_count -F querywork/rq$1.res`

   if [ "$rescount" == "No Status" ]; then
      rescount=0
   fi

   echo "expected-results was $expres, expected $origcount"
   echo "returned-urls was $rescount, expected $returnedurls"

   if [ $rescount -eq $returnedurls ]; then
      if [ $origcount -eq $expres ]; then
         echo "Case $1:  Test Passed"
         echo "########################################"
         return
      fi
   fi

   echo "Case $1:  Test Failed"
   echo "   Expected URL count: $origcount"
   echo "   Actual URL count:   $rescount"
   results=`expr $results + 1`
   echo "########################################"
   return
}

#####################################################################

casecount=`expr $casecount + 9`
test_header $VCOLLECTION $DESCRIPTION

#repository_update -F wc_options -N

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="7.5"
fi

#source $TEST_ROOT/lib/run_std_setup.sh

#crawl_check $SHOST $VCOLLECTION

run_case 1 Hamilton "a*" 3871 100
run_case 2 Hamilton "a* b*" 4252 100
run_case 3 Hamilton "a* b* c*" 4174 100
run_case 4 Hamilton "a* AND b* AND c* AND d* AND e* AND f* AND g* AND h* AND i* AND j* AND k* AND l* AND m* AND n* AND o* AND p* AND q* AND r* AND s* AND t* AND u* AND v* AND w* AND x* AND y* AND z* AND *a AND *b AND *c AND *d AND *e AND *f AND *g AND *h AND *i AND *j AND *k AND *l AND *m AND *n AND *o AND *p AND *q AND *r AND *s AND *t AND *u AND *v AND *w AND *x AND *y AND *z AND A* AND E* AND I* AND O* AND U* AND 0* AND 1* AND 2* AND 3* AND 4* AND 5* AND 6* AND 7* AND 8* AND 9* AND 0* AND *0 AND *1 AND *2 AND *3 AND *4 AND *5 AND *6 AND *7 AND *8 AND *9 AND A* AND B* AND C* AND D* AND E* AND F* AND G* AND H* AND I* AND J* AND K* AND L* AND M* AND N* AND O* AND P* AND Q* AND R* AND S* AND T* AND U* AND V* AND W* AND X* AND Y* AND Z*" 100 100
run_case 5 Hamilton "a* OR b* OR c* OR d* OR e* OR f* OR g* OR h* OR i* OR j* OR k* OR l* OR m* OR n* OR o* OR p* OR q* OR r* OR s* OR t* OR u* OR v* OR w* OR x* OR y* OR z* OR *a OR *b OR *c OR *d OR *e OR *f OR *g OR *h OR *i OR *j OR *k OR *l OR *m OR *n OR *o OR *p OR *q OR *r OR *s OR *t OR *u OR *v OR *w OR *x OR *y OR *z OR A* OR E* OR I* OR O* OR U* OR 0* OR 1* OR 2* OR 3* OR 4* OR 5* OR 6* OR 7* OR 8* OR 9* OR 0* OR *0 OR *1 OR *2 OR *3 OR *4 OR *5 OR *6 OR *7 OR *8 OR *9 OR A* OR B* OR C* OR D* OR E* OR F* OR G* OR H* OR I* OR J* OR K* OR L* OR M* OR N* OR O* OR P* OR Q* OR R* OR S* OR T* OR U* OR V* OR W* OR X* OR Y* OR Z*" 5265 100
run_case 6 Hamilton "NOT (a* OR b* OR c* OR d* OR e* OR f* OR g* OR h* OR i* OR j* OR k* OR l* OR m* OR n* OR o* OR p* OR q* OR r* OR s* OR t* OR u* OR v* OR w* OR x* OR y* OR z* OR *a OR *b OR *c OR *d OR *e OR *f OR *g OR *h OR *i OR *j OR *k OR *l OR *m OR *n OR *o OR *p OR *q OR *r OR *s OR *t OR *u OR *v OR *w OR *x OR *y OR *z OR A* OR E* OR I* OR O* OR U* OR 0* OR 1* OR 2* OR 3* OR 4* OR 5* OR 6* OR 7* OR 8* OR 9* OR 0* OR *0 OR *1 OR *2 OR *3 OR *4 OR *5 OR *6 OR *7 OR *8 OR *9 OR A* OR B* OR C* OR D* OR E* OR F* OR G* OR H* OR I* OR J* OR K* OR L* OR M* OR N* OR O* OR P* OR Q* OR R* OR S* OR T* OR U* OR V* OR W* OR X* OR Y* OR Z*)" 4 4
run_case 7 Hamilton "NOT (a* AND b* AND c* AND d* AND e* AND f* AND g* AND h* AND i* AND j* AND k* AND l* AND m* AND n* AND o* AND p* AND q* AND r* AND s* AND t* AND u* AND v* AND w* AND x* AND y* AND z* AND *a AND *b AND *c AND *d AND *e AND *f AND *g AND *h AND *i AND *j AND *k AND *l AND *m AND *n AND *o AND *p AND *q AND *r AND *s AND *t AND *u AND *v AND *w AND *x AND *y AND *z AND A* AND E* AND I* AND O* AND U* AND 0* AND 1* AND 2* AND 3* AND 4* AND 5* AND 6* AND 7* AND 8* AND 9* AND 0* AND *0 AND *1 AND *2 AND *3 AND *4 AND *5 AND *6 AND *7 AND *8 AND *9 AND A* AND B* AND C* AND D* AND E* AND F* AND G* AND H* AND I* AND J* AND K* AND L* AND M* AND N* AND O* AND P* AND Q* AND R* AND S* AND T* AND U* AND V* AND W* AND X* AND Y* AND Z*)" 5214 100
#
#   Since we messed with the repository, we need
#   to delete the collection so we can put the repository
#   back the way it was.
#
#   Also, since we killed the collection, the error report
#   is now invalid as far as we are concerned.
#
VIVERRORREPORT="False"
#delete_collection -C $VCOLLECTION
#repository_delete -t options -n query-meta

#source $TEST_ROOT/lib/run_std_results.sh
