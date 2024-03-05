#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="wildcard-jpn"
   DESCRIPTION="Wildcard test of Japanese files"
   TARGETHOST=${VIV_SAMBA_LINUX_SERVER}

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

run_case()
{
   echo "########################################"
   echo "Case $1:  $2 as $3"
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$3" -n 5000
   count_urls -F querywork/rq$1.res > querywork/rq$1.resuri
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.resuri
   count_urls -F query_cmp_files/rq$1.cmp > querywork/rq$1.origuri
   sort_query_urls -F query_cmp_files/rq$1.cmp >> querywork/rq$1.origuri
   diff querywork/rq$1.origuri querywork/rq$1.resuri > querywork/rq$1.diff
   x=$?
   if [ $x -eq 0 ]; then
      echo "Case $1:  Test Passed"
   else
      echo "Case $1:  Test Failed"
   fi
   echo "########################################"
   results=`expr $results + $x`
}

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

repository_update -F wc_options -N

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

for file in query_cmp_files/r*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
run_case 1 "" ""
run_case 2 "個人情報を収集する目的" "?*を収集する目的"
run_case 3 "個人情報を収集する目的" "?収集"
run_case 4 "個人情報を収集する目的" "*情報"
run_case 5 "個人情報を収集する目的" "?*情報"
run_case 6 "利用目的" "利用目的"
run_case 7 "収集" "収集"
run_case 8 "個人情報を収集する目的" "情報?"
run_case 9 "個人情報を収集する目的" "情*"

#
#   Since we messed with the repository, we need
#   to delete the collection so we can put the repository
#   back the way it was.
#
#
#   is no invalid as far as we are concerned.
#
VIVERRORREPORT="False"
#delete_collection -C $VCOLLECTION
#repository_delete -t options -n query-meta

rm ${VCOLLECTION}.xml
rm query_cmp_files/r*

source $TEST_ROOT/lib/run_std_results.sh
