#!/bin/bash

XSLLIB=$TEST_ROOT/tests/xslt/XSLT_LIB
XSLINCLUDE=$TEST_ROOT/tests/xslt/XSLT_INCLUDE
ln -s $XSLINCLUDE include 2>/dev/null
ln -s $XSLINCLUDE $XSLLIB/include 2>/dev/null

transform -xsl vivToMixed.xsl vivToMixed.xml 2> trashfile > vivToMixed.res

tranres=$?

if [ $tranres == 0 ]; then
   fres=`grep "TEST FAILED" vivToMixed.res`
   if [[ $fres == "" ]]; then
      echo ""
      echo "vivToMixed:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivToMixed:  Test Failed"

exit 1
