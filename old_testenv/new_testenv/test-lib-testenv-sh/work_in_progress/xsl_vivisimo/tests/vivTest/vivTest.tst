#!/bin/bash

x=`ls vivTest[0-9][0-9]*.xml`
failtot=0

if [ -f result.html ]; then
   rm result.html
fi

for item in $x; do
   xsltproc ../../lib/xslGen.xsl $item > vivTest.xsl
   transform -xsl vivTest.xsl ../../lib/dummy.xml 2> trashfile >> result.html
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
      echo "vivTest:  Test Passed"
      exit 0
   fi
   echo $fres
fi

echo ""
echo "vivTest:  Test Failed, $failtot"

exit 1
