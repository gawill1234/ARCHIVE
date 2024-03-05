#!/bin/bash

transform -xsl vivToLower.xsl vivToLower.xml 2> trashfile > vivToLower.res

tranres=$?

if [ $tranres == 0 ]; then
   fres=`grep "TEST FAILED" vivToLower.res`
   if [[ $fres == "" ]]; then
      echo ""
      echo "vivToLower:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivToLower:  Test Failed"

exit 1
