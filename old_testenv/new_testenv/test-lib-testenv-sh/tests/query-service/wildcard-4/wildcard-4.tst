#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="wildcard-4"
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
   run_query -S $VCOLLECTION -O querywork/rq$1.res -Q "$3" -n 5000
   rescount=`count_urls -F querywork/rq$1.res`
   sort_query_urls -F querywork/rq$1.res >> querywork/rq$1.resuri
   if [ $origcount -eq 0 ]; then
      origcount=`count_urls -F query_cmp_files/qry.$2.xml.cmp`
   fi
   sort_query_urls -F query_cmp_files/qry.$2.xml.cmp >> querywork/rq$1.origuri
   diff querywork/rq$1.origuri querywork/rq$1.resuri > querywork/rq$1.diff
   x=$?
   if [ $rescount -eq $origcount ]; then
      echo "Case $1:  Test Passed"
   else
      echo "Case $1:  Test Failed"
      echo "   Expected URL count: $origcount"
      echo "   Actual URL count:   $rescount"
      results=`expr $results + 1`
   fi
   echo "########################################"
}

#####################################################################

casecount=`expr $casecount + 9`
test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
fi

if [ -z "$VIVTARGETOS" ]; then
   export VIVTARGETOS="linux"
fi

majorversion=`getmajorversion`

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

for file in query_cmp_files/qry*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

if [ "$VIVTARGETOS" == "solaris" ]; then
   run_case 1 Hamilton "Hamil*" 3
   run_case 2 "Hamilton+Madison" "Hamil* Madi*" 3
   run_case 3 Linux "Linux" 5
   run_case 4 Stinkybottom "Stinkyb??*om" 0
   run_case 5 We+the+people "We the people" 16
   run_case 6 We+the+people "We the peo*le" 16
   run_case 7 Linux "*inux" 5
   run_case 8 Linux "Lin*x" 5
   run_case 9 Linux "Li**ux" 5
else
   run_case 1 Hamilton "Hamil*" 4
   run_case 2 "Hamilton+Madison" "Hamil* Madi*" 4
   run_case 3 Linux "Linux" 0
   run_case 4 Stinkybottom "Stinkyb??*om" 0
   run_case 5 We+the+people "We the people" 18
   run_case 6 We+the+people "We the peo*le" 18
   run_case 7 Linux "*inux" 0
   run_case 8 Linux "Lin*x" 0
   run_case 9 Linux "Li**ux" 0
fi

#
#   Since we killed the collection, the error report
#   is no invalid as far as we are concerned.
#
VIVERRORREPORT="False"
delete_collection -C $VCOLLECTION

rm ${VCOLLECTION}.xml
rm query_cmp_files/qry*

source $TEST_ROOT/lib/run_std_results.sh
