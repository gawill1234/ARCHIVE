#!/bin/bash

transform -xsl vivToUpper.xsl vivToUpper.xml 2> trashfile > vivToUpper.res

tranres=$?

if [ $tranres == 0 ]; then
   fres=`grep "TEST FAILED" vivToUpper.res`
   if [[ $fres == "" ]]; then
      echo ""
      echo "vivToUpper:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivToLower:  Test Failed"

exit 1
