#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="thai-2"
   DESCRIPTION="Basic touch test for Thai segmentation (all versions)"

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
   count_urls -F query_cmp_files/qry.$2.xml.cmp > querywork/rq$1.origuri
   sort_query_urls -F query_cmp_files/qry.$2.xml.cmp >> querywork/rq$1.origuri
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

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

run_case 1 1 "สำหรับ"
run_case 2 2 องค์การอนามัยโลก
run_case 3 3 ความปลอดภัย
run_case 4 4 ＣＨＩＬＬ
run_case 5 5 "แอร์พอร์ตลิงค์เตรียมเปิดทดลองให้บริการฟรี 5 ธ ค นี้.msg"
run_case 6 6 "รักษา  เดินรถ"
run_case 7 7 รักษา  เดินรถ

delete_collection -C $VCOLLECTION

exit $results
