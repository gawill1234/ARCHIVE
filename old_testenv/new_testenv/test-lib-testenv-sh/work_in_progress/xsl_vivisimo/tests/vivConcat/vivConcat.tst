#!/bin/bash

XSLLIB=$TEST_ROOT/tests/xslt/XSLT_LIB
XSLINCLUDE=$TEST_ROOT/tests/xslt/XSLT_INCLUDE
ln -s $XSLINCLUDE include 2>/dev/null
ln -s $XSLINCLUDE $XSLLIB/include 2>/dev/null

x=`ls vivConcat[0-9][0-9]*.xml`
failtot=0

if [ -f result.html ]; then
   rm result.html
fi

for item in $x; do
   xsltproc $XSLLIB/xslGen.xsl $item > vivConcat.xsl
   transform -xsl vivConcat.xsl $XSLLIB/nodes2.xml 2> trashfile >> result.html
   tranres=$?
   if [ $tranres != 0 ]; then
      failtot=`expr $failtot + 1`
      echo "$item failure"
   fi
done


if [ $failtot == 0 ]; then
   fres=`grep "TEST FAILED" result.html`
   if [[ $fres == "" ]]; then
      echo ""
      echo "vivConcat:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivConcat:  Test Failed, $failtot"

exit 1
