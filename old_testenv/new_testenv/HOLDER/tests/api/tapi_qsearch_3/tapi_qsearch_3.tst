#!/bin/bash

echo $CLASSPATH

if [ -f tapi_qsearch_3.class ]; then
   rm tapi_qsearch_3.class
fi

if [ -f tapi_qsearch_3.java ]; then
   javac tapi_qsearch_3.java
else
   echo "tapi_qsearch_3:  file tapi_qsearch_3.java is missing"
fi

if [ -f tapi_qsearch_3.class ]; then
   rm -rf logs
   rm -rf querywork

   java tapi_qsearch_3 --collection-name qsrch1
   blah=$?

   rm tapi_qsearch_3.class

   if [ $blah -eq 0 ]; then
      echo "tapi_qsearch_3:  Test Passed"
      exit 0
   fi
else
   echo "tapi_qsearch_3:  file tapi_qsearch_3.class is missing"
fi

echo "tapi_qsearch_3:  Test Failed"
exit 1
