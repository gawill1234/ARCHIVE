#!/bin/bash

tfile=`basename $0`

tname=`echo $tfile | sed "s/\.tst//"`

cname="$tname.class"
jname="$tname.java"

source $TEST_ROOT/env.setup/set_test_class_path

if [ -f $cname ]; then
   rm $cname
fi

if [ -f $jname ]; then
   javac $jname
else
   echo "$tname:  file $jname is missing"
fi

if [ -f $cname ]; then

   java $tname
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
