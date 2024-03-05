#!/bin/bash

source $TEST_ROOT/set_test_class_path

if [ -f bug25367.class ]; then
   rm bug25367.class
fi

if [ -f bug25367.java ]; then
   javac bug25367.java
else
   echo "bug25367:  file bug25367.java is missing"
fi

if [ -f bug25367.class ]; then

   java bug25367
   blah=$?

   if [ $blah -eq 0 ]; then
      echo "bug25367:  Test Passed"
      exit $blah
   fi

else
   echo "bug25367:  file bug25367.class is missing"
fi

echo "bug25367:  Test Failed"
exit 1
