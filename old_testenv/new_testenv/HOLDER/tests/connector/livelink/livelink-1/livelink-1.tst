#!/bin/bash

#
#   If you need to clean up the livelink source, run
#   livelink-del-2.  It will put the source back in to
#   its original state.
#
tname="livelink-1"

echo "============================================"
echo "livelink-1:  This runs a series of tests using the livelink"
echo "             connector.  Each test will have its own pass/fail"
echo "             value leading to the global pass/fail for $tname"
echo "============================================"
echo "livelink-1:  livelink-init is an initialization test.  It is designed"
echo "             to pass not matter what.  Failure indicates a big problem."
echo "============================================"
echo "livelink-1:  livelink-add-1 adds 2 directories of documents and does"
echo "             an inplace refresh."
echo "============================================"
echo "livelink-1:  livelink-del-1 deletes one fo the directories just added"
echo "             (containing 3 docs) and does an inplace refresh."
echo "============================================"
echo "livelink-1:  livelink-del-2 deletes the other added directory and does"
echo "             an inplace refresh.  It should have the same number of docs"
echo "             as it did at the end of livelink-init."
echo "============================================"
echo "livelink-1:  livelink-add-2 adds 2 directories.  One is the same as one"
echo "             of the previous ones plus a new one.  It does inplace"
echo "             refresh.  livelink-new-1 adds no documents but does a new"
echo "             crawl in staging.  It should have the same results as"
echo "             livelink-add-2."
echo "============================================"
echo "livelink-1:  livelink-del-3 delete 2 documents and does an inplace"
echo "             refresh."
echo "============================================"
echo "livelink-1:  livelink-new-2 adds no documents (no deletes either) and"
echo "             does a new crawl in staging.  Should have the same results"
echo "             as livelink-del-3 did."
echo "============================================"
echo "livelink-1:  livelink-del-2 deletes all added directories.  It does an"
echo "             inplace refresh.  Should have the same documents as were"
echo "             created by livelink-init."
echo "============================================"


MySite="192.168.0.146"
MyUser="Admin"
MyPw="livelink"
MyCollection="blahblah"

#
#   livelink-1.tst -U fuzzy-lumpkin -P fuzzy2
#   will make the following values be true:
#
#   MyUser="fuzzy-lumpkin"
#   MyPw="fuzzy2"
#
#   This will cause the crawl and document creation/removal to be
#   done by that livelink user.
#

while getopts "U:S:P:F:C:" flag; do
   case "$flag" in
      U) MyUser=$OPTARG;;
      S) MySite=$OPTARG;;
      C) MyCollection=$OPTARG;;
      P) MyPw=$OPTARG;;
      F) forwardit="$forwardit $OPTARG";;
      *) echo "Bad option"
         exit;;
   esac
done

./setup_test -U $MyUser -S $MySite -P $MyPw -C $MyCollection

run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -delete directory -mountpoint /Enterprise -itemname testenv


echo "============================================"
echo "START:  livelink-init"
./livelink-init.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection
t1=$?
echo "============================================"
echo "============================================"
echo "BASE EMPTY QUERY COUNT:  $t1"
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-add-1"
./livelink-add-1.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t2=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-del-1"
./livelink-del-1.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t3=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-del-2(first run)"
./livelink-del-2.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t4=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-add-2"
./livelink-add-2.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t5=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-new-1"
./livelink-new-1.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t6=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-del-3"
./livelink-del-3.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t7=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-new-2"
./livelink-new-2.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t8=$?
echo "============================================"
sleep 5
echo "============================================"
echo "START:  livelink-del-2(second run)"
./livelink-del-2.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t9=$?
echo "============================================"

echo "==========================================="
if [ $t1 -le 0 ]; then
   echo "TEST:  livelink-init failed"
else
   echo "TEST:  livelink-init passed"
fi
echo "       Initial crawl of base data."
echo "==========================================="
if [ $t2 -ne 0 ]; then
   echo "TEST:  livelink-add-1 failed"
else
   echo "TEST:  livelink-add-1 passed"
fi
echo "       Refresh after adding 2 directories with many files"
echo "==========================================="
if [ $t3 -ne 0 ]; then
   echo "TEST:  livelink-del-1 failed"
else
   echo "TEST:  livelink-del-1 passed"
fi
echo "       Refresh after deleting a directory"
echo "==========================================="
if [ $t4 -ne 0 ]; then
   echo "TEST:  livelink-del-2(run 1) failed"
else
   echo "TEST:  livelink-del-2(run 1) passed"
fi
echo "       Refresh after all data except initial data deleted"
echo "==========================================="
if [ $t5 -ne 0 ]; then
   echo "TEST:  livelink-add-2 failed"
else
   echo "TEST:  livelink-add-2 passed"
fi
echo "       Refresh many files have been added."
echo "==========================================="
if [ $t6 -ne 0 ]; then
   echo "TEST:  livelink-new-1 failed"
else
   echo "TEST:  livelink-new-1 passed"
fi
echo "       Recrawl of livelink-add-2 data using new/staging"
echo "==========================================="
if [ $t7 -ne 0 ]; then
   echo "TEST:  livelink-del-3 failed"
else
   echo "TEST:  livelink-del-3 passed"
fi
echo "       Refresh after 2 files have been deleted."
echo "==========================================="
if [ $t8 -ne 0 ]; then
   echo "TEST:  livelink-new-2 failed"
else
   echo "TEST:  livelink-new-2 passed"
fi
echo "       Recrawl of livelink-del-3 data using new/staging"
echo "==========================================="
if [ $t9 -ne 0 ]; then
   echo "TEST:  livelink-del-2(run 2) failed"
else
   echo "TEST:  livelink-del-2(run 2) passed"
fi
echo "       All data except initial data deleted"
echo "==========================================="

final=`expr $t2 + $t3 + $t4 + $t5 + $t6 + $t7 + $t8 + $t9`

if [ $final -eq 0 ]; then
   echo "$0:  Test Passed"
else
   echo "$0:  Test Failed"
fi

exit $final
