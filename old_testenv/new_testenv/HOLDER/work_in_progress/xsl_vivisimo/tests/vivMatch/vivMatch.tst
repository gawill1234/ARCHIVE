#!/bin/bash

XSLLIB=$TEST_ROOT/tests/xslt/XSLT_LIB
XSLINCLUDE=$TEST_ROOT/tests/xslt/XSLT_INCLUDE
ln -s $XSLINCLUDE include 2>/dev/null
ln -s $XSLINCLUDE $XSLLIB/include 2>/dev/null

transform -xsl vivMatch.xsl vivMatch.xml 2> trashfile > vivMatch.res

tranres=$?

if [ $tranres == 0 ]; then
   fres=`grep "TEST FAILED" vivMatch.res`
   if [[ $fres == "" ]]; then
      echo ""
      echo "vivMatch:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivMatch:  Test Failed"

exit 1
