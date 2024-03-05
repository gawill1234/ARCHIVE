#!/bin/bash

#####################################################################

###
#   Global stuff
###
#
#   This tests is a copy of samba-1, a complete copy.  The only
#   difference is that in this tests, compression is enabled.
#
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="compression-2"
   DESCRIPTION="samba crawl and search of various doc types with compression"

###
###

export VIVDEFCONVERT="true"
export VIVLOWVERSION=6.1

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

test_header $VCOLLECTION $DESCRIPTION

if [ -z "$VIVVERSION" ]; then
   export VIVVERSION="6.0"
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

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION Hamilton
basic_query_test 2 $SHOST $VCOLLECTION Hamilton+Madison
basic_query_test 3 $SHOST $VCOLLECTION Linux
basic_query_test 4 $SHOST $VCOLLECTION Stinkybottom
basic_query_test 5 $SHOST $VCOLLECTION We+the+people
basic_query_test 6 $SHOST $VCOLLECTION Drahtmüller

diff_match_counts Hamilton
diff_match_counts Hamilton+Madison
diff_match_counts Linux
diff_match_counts Stinkybottom
diff_match_counts We+the+people
diff_match_counts Drahtmüller

diff_titles Hamilton
diff_titles Hamilton+Madison
diff_titles Linux
diff_titles Stinkybottom
diff_titles We+the+people
diff_titles Drahtmüller

rm ${VCOLLECTION}.xml
rm query_cmp_files/qry*

source $TEST_ROOT/lib/run_std_results.sh
