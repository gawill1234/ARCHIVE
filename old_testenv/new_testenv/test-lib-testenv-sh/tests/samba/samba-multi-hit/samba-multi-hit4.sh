#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   BASECOLLECTION="samba-multi-hit"
   VCOLLECTION="samba-multi-hit4"
   DESCRIPTION="samba crawl of one tar file"

###
###

export VIVDEFCONVERT="true"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

local_footer()
{
#####################################################################

###
#   This defines the standard PASS/FAIL output for all of the
#   crawl/query tests.
###

if [ $results -eq 0 ]; then
   echo "TEST RESULT FOR $1:  Test Passed"
   exit 0
fi

echo "TEST RESULT FOR $1:  Test Failed"
echo "$1:  $2 of $3 cases failed"
exit 1

#####################################################################
}


#####################################################################

test_header $VCOLLECTION $DESCRIPTION

sed s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${BASECOLLECTION}.xml > ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

cp $BASECOLLECTION.xml.stats $VCOLLECTION.xml.stats

RUNCOUNT=$1

getsetopts $*

count=0
while [ $count -lt $RUNCOUNT ]; do
   count=`expr $count + 1`
   echo "$VCOLLECTION:  PASS $count"

   cleanup $SHOST $VCOLLECTION $VUSER $VPW
   setup $SHOST $VCOLLECTION $VUSER $VPW

   crawl_check $SHOST $VCOLLECTION

   if [ $results -ne 0 ]; then
      rm $VCOLLECTION.xml $VCOLLECTION.xml.stats
      get_url_errors -C $VCOLLECTION -h testbed5.test.vivisimo.com
      echo "$VCOLLECTION:  Test Failed"
      ./killer.sh
      exit 1
   fi
done

rm $VCOLLECTION.xml $VCOLLECTION.xml.stats

echo "COMPLETED:  $VCOLLECTION"

local_footer $VCOLLECTION $results $casecount $SHOST $VUSER $VPW
