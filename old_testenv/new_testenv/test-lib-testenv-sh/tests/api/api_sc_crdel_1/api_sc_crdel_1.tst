#!/bin/bash

echo $CLASSPATH

if [ -f api_sc_crdel_1.class ]; then
   rm api_sc_crdel_1.class
fi

if [ -f api_sc_crdel_1.java ]; then
   javac api_sc_crdel_1.java
else
   echo "api_sc_crdel_1:  file api_sc_crdel_1.java is missing"
fi

if [ -f api_sc_crdel_1.class ]; then
   java api_sc_crdel_1
   blah=$?

   rm api_sc_crdel_1.class

   if [ $blah -eq 0 ]; then
      echo "api_sc_crdel_1:  Test Passed"
      exit 0
   fi
else
   echo "api_sc_crdel_1:  file api_sc_crdel_1.class is missing"
fi

echo "api_sc_crdel_1:  Test Failed"
exit 1
