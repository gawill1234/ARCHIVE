#!/bin/bash

if [ ! -f buildit ]; then
   tar -xvf build.tar
fi

if ! hash ant; then
   echo "ant is required to run this test"
   echo "api-simple-java-run:  Test Failed"
   exit 1
fi

cd buildit

if [ "$VIVTARGETOS" == "windows" ]; then
   ant -Dwsdl.uri="http://$VIVHOST/vivisimo/cgi-bin/velocity.exe?v.app=api-soap&use-types=true&wsdl=1"
   ares=$?
else
   ant -Dwsdl.uri="http://$VIVHOST/vivisimo/cgi-bin/velocity?v.app=api-soap&use-types=true&wsdl=1"
   ares=$?
fi

if [ $ares -ne 0 ]; then
   echo "Test build failed"
   echo "api-simple-wsdl-build:  Test Failed"
   exit 1
fi

./build.sh
arunres=$?

if [ $arunres -ne 0 ]; then
   echo "Run failed"
   echo "api-simple-wsdl-build:  Test Failed"
   exit 1
fi

echo "api-simple-wsdl-build:  Test Passed"
exit 0
