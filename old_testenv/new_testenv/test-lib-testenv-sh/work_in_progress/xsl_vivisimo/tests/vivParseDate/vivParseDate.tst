#!/bin/bash

ln -s $TEST_ROOT/work_in_progress/xsl_vivisimo/includes includes

transform -xsl vivParseDate.xsl vivParseDate.xml 2> trashfile > vivParseDate.res

tranres=$?

if [ $tranres == 0 ]; then
   fres=`grep "TEST FAILED" vivParseDate.res`
   if [[ $fres == "" ]]; then
      echo ""
      echo "vivParseDate:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivParseDate:  Test Failed"

exit 1
