#!/bin/bash

test_description()
{
   echo "$tname:  livelink refresh crawl after documents added."
   echo "$tname:  This assumes the collection in question exists."
}

load_the_data()
{
   echo "=================================================="
   echo "$tname:  Loading up added data to livelink"
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/document/DOCX
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/document/DOC
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/1
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/2
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/3
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/4
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/5
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/6
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/7
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/8
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/9
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/10
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/11
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/12
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/13
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/14
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/15
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/16
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/17
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/18
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/19
   run_bulk_loader -site $MySite -connector livelink -user $MyUser -pw $MyPw -create tree -mountpoint /testenv/test_data/law/US/20
   echo "=================================================="
}

tfile=`basename $0`
gt="generalTest"

MySite="192.168.0.146"
#MySite="10.7.8.249"
MyUser="Admin"
MyPw="livelink"
NQCAdd=0
MyCollection="ll_load"

forwardit=""

while getopts "C:B:U:S:P:F:" flag; do
   case "$flag" in
      U) MyUser=$OPTARG;;
      S) MySite=$OPTARG;;
      C) MyCollection=$OPTARG;;
      P) MyPw=$OPTARG;;
      B) NQCAdd=$OPTARG;;
      F) forwardit="$forwardit $OPTARG";;
      *) echo "Bad option"
         exit;;
   esac
done

qcnt=`expr $NQCAdd + 893`

tname=`echo $tfile | sed "s/\.tst//"`
echo "$tname:  EXPECTED NULL QUERY COUNT = $qcnt"

cname="$gt.class"
jname="$TEST_ROOT/tests/generics/$gt.java"

#source $TEST_ROOT/env.setup/set_test_class_path

if [ ! -e $cname ]; then
   if [ -e $jname ]; then
      javac $jname -d .
   else
      echo "$tname:  file $jname is missing"
   fi
fi

if [ -e $cname ]; then

   test_description

   load_the_data

   java $gt -tname $tname -collection $MyCollection -crawlmode "refresh-inplace" -nosetup -noteardown -query alarm 11 -query clusty 5 -query custom 118 -query "" $qcnt $forwardit
   blah=$?

   if [ $blah -eq 0 ]; then
      echo "$tname:  Test Passed"
      exit $blah
   fi

else
   echo "$tname:  file $cname is missing"
fi

echo "$tname:  Test Failed"
exit 1
