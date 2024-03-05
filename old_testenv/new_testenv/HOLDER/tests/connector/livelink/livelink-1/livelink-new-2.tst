#!/bin/bash

test_description()
{
   echo "$tname:  New crawl in staging to overwrite live."
   echo "$tname:  Should have identical final results to del-3."
}

tfile=`basename $0`
gt="generalTest"

MyUser="Admin"
MySite="192.168.0.146"
MyPw="livelink"
MyCollection="blahblah"
NQCAdd=0

forwardit=""

while getopts "B:U:S:P:F:C:" flag; do
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

qcnt=`expr $NQCAdd + 69`

tname=`echo $tfile | sed "s/\.tst//"`
echo "$tname:  EXPECTED NULL QUERY COUNT = $qcnt"

cname="$gt.class"
jname="$TEST_ROOT/tests/generics/$gt.java"

#source $TEST_ROOT/env.setup/set_test_class_path

if [ -f $cname ]; then
   rm $cname
fi

if [ -f $jname ]; then
   javac $jname -d .
else
   echo "$tname:  file $jname is missing"
fi

if [ -f $cname ]; then

   test_description

   java $gt -tname $tname -subcollection staging -crawlmode new -collection $MyCollection -nosetup -noteardown -query "" $qcnt $forwardit
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
