#!/bin/bash

test_description()
{
   echo "$tname:  livelink generic test"
}

tfile=`basename $0`
gt="generalTest"

MyUser="Admin"
MySite="192.168.0.146"
MyPw="livelink"
MyCollection="ll_load"

forwardit=""

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


tname=`echo $tfile | sed "s/\.tst//"`

cname="$gt.class"
jname="$TEST_ROOT/tests/generics/$gt.java"

#source $TEST_ROOT/env.setup/set_test_class_path

if [ $VIVTARGETOS == "linux" ]; then
   echo "$tname:  Copying $MyCollection.xml from $MyCollection.xml.linux"
   echo "         Yes, $MyCollection is the right name"
   cp $MyCollection.xml.linux $MyCollection.xml
else
   echo "$tname:  Copying $MyCollection.xml from $MyCollection.xml.windows"
   echo "         Yes, $MyCollection is the right name"
   cp $MyCollection.xml.windows $MyCollection.xml
fi

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

   java $gt -tname $tname -collection $MyCollection -noteardown $forwardit -ewlqv
   blah=$?

   if [ $blah -gt 0 ]; then
      echo "$tname:  EXPECTED NULL QUERY COUNT = $blah"
      echo "$tname:  Test Passed"
      exit $blah
   fi

else
   echo "$tname:  file $cname is missing"
fi

echo "$tname:  Test Failed"
exit 1
