#!/bin/bash

#
#   If you need to clean up the livelink source, run
#   livelink-del-2.  It will put the source back in to
#   its original state.
#
tname="livelink-load"

echo "============================================"
echo "livelink-load:  This runs a series of tests using the livelink"
echo "                connector.  The test is designed to put at leas"
echo "                some load on livelink.  The crawl time is output"
echo "                as part of the test."
echo "                Each test will have its own pass/fail"
echo "                value leading to the global pass/fail for $tname"
echo "============================================"
echo "livelink-load:  livelink-init is an initialization test.  It is designed"
echo "                to pass no matter what.  Failure indicates a big problem."
echo "============================================"
echo "livelink-load:  livelink-runload adds many directories of documents"
echo "                and does an inplace refresh."
echo "============================================"
echo "livelink-load:  livelink-newload recrawls the data from livelink-runload"
echo "                with no changes but does a new crawl in staging."
echo "============================================"
echo "livelink-load:  livelink-unload removes all added directories of"
echo "                documents and does an inplace refresh."
echo "============================================"


MySite="192.168.0.146"
MyUser="Admin"
MyPw="livelink"
MyCollection="ll_load"

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
echo "START:  livelink-runload"
./livelink-runload.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t2=$?
echo "============================================"
echo "START:  livelink-newload"
./livelink-newload.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t3=$?
echo "============================================"
echo "START:  livelink-unload"
./livelink-unload.tst -U $MyUser -S $MySite -P $MyPw -C $MyCollection -B $t1
t4=$?
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
   echo "TEST:  livelink-runload failed"
else
   echo "TEST:  livelink-runload passed"
fi
echo "       Refresh after adding 2 directories with many files"
echo "==========================================="
if [ $t3 -ne 0 ]; then
   echo "TEST:  livelink-newload failed"
else
   echo "TEST:  livelink-newload passed"
fi
echo "       Refresh after adding 2 directories with many files"
echo "==========================================="
if [ $t4 -ne 0 ]; then
   echo "TEST:  livelink-unload failed"
else
   echo "TEST:  livelink-unload passed"
fi
echo "       Refresh after adding 2 directories with many files"
echo "==========================================="

final=`expr $t2 + $t3 + $t4`

if [ $final -eq 0 ]; then
   echo "$0:  Test Passed"
else
   echo "$0:  Test Failed"
fi

exit $final
