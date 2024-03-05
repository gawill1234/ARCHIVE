#!/bin/bash

if [ ! -f "testit" ]; then
   tar -xvf test.tar
fi

if ! hash ant; then
   echo "ant is required to run this test"
   echo "api-simple-java-run:  Test Failed"
   exit 1
fi

cd testit

ant
ares=$?

if [ $ares -ne 0 ]; then
   echo "Test build failed"
   echo "api-simple-java-run:  Test Failed"
   exit 1
fi

if [ "$VIVTARGETOS" == "windows" ]; then
   ant run -Durl="http://$VIVHOST/vivisimo/cgi-bin/velocity.exe" -Duser=$VIVUSER -Dpassword=$VIVPW
else
   ant run -Durl="http://$VIVHOST/vivisimo/cgi-bin/velocity" -Duser=$VIVUSER -Dpassword=$VIVPW
fi

arunres=$?

if [ $arunres -ne 0 ]; then
   echo "Run failed"
   echo "api-simple-java-run:  Test Failed"
   exit 1
fi

cd ..

rescount=`wc -l testit/urls.txt | cut -f 1 -d ' '`
origcount=`count_urls -F query_cmp_files/qry.Linux.xml.cmp`

if ! [ "$origcount" -eq "$rescount" ]; then
   echo "Query url count mismatch"
   echo "   Expected:  $origcount"
   echo "   Actual:    $rescount"
   echo "api-simple-java-run:  Test Failed"
   exit 1
fi

echo "Query url count matched"
echo "   Expected:  $origcount"
echo "   Actual:    $rescount"

delete_collection -C test-suite-collection

echo "api-simple-java-run:  Test Passed"
exit 0
