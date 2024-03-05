#!/bin/bash

test_description()
{
   echo "$tname:  confluence user is admin and has access to"
   echo "$tname:  all private data"
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

   java $gt -tname $tname -collection barfly -query fuck 1 -query shit 2 -query "" 298 $*
   blah=$?

   #if [ $1 == "scooter" ]; then
   #   java $tname -collection $1 -query fuck 0 -query shit 1 -query "" 289
   #   blah=$?
   #fi

   if [ $blah -eq 0 ]; then
      echo "$tname:  Test Passed"
      exit $blah
   fi

else
   echo "$tname:  file $cname is missing"
fi

echo "$tname:  Test Failed"
exit 1
