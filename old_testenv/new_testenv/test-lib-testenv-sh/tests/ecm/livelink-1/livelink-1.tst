#!/bin/bash

test_description()
{
   echo "$tname:  livelink generic test"
}

tfile=`basename $0`
gt="generalTest"

tname=`echo $tfile | sed "s/\.tst//"`

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

   java $gt -tname $tname -collection blahblah -query fuck 5 -query lawyer 134 $*
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