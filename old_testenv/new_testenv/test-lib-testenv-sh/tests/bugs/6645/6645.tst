#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="6645"
   DESCRIPTION="textfile with embedded nuls"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

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

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION 9802
basic_query_test 2 $SHOST $VCOLLECTION 00000181525
basic_query_test 3 $SHOST $VCOLLECTION 264453

rm ${VCOLLECTION}.xml
rm query_cmp_files/qry*

source $TEST_ROOT/lib/run_std_results.sh