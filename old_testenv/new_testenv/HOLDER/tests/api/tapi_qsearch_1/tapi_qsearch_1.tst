#!/bin/bash

echo $CLASSPATH

if [ -f urls-1.txt ]; then
   rm urls-1.txt
fi
if [ -f urls-2.txt ]; then
   rm urls-2.txt
fi
if [ -f urls-3.txt ]; then
   rm urls-3.txt
fi

if [ -f tapi_qsearch_1.class ]; then
   rm tapi_qsearch_1.class
fi

if [ -f tapi_qsearch_1.java ]; then
   javac tapi_qsearch_1.java
else
   echo "tapi_qsearch_1:  file tapi_qsearch_1.java is missing"
fi

if [ -f tapi_qsearch_1.class ]; then
   rm -rf logs
   rm -rf querywork

   mkdir querywork

   java tapi_qsearch_1 --collection-name qsrch1
   blah=$?

   if [ -f querywork/urls-1.txt ]; then
      acnt=`wc -l querywork/urls-1.txt | cut -f 1 -d " "`
   else
      echo "tapi_qsearch_1:  file urls-1.txt is missing"
      acnt=0
   fi
   if [ -f querywork/urls-2.txt ]; then
      bcnt=`wc -l querywork/urls-2.txt | cut -f 1 -d " "`
   else
      echo "tapi_qsearch_1:  file urls-2.txt is missing"
      bcnt=0
   fi
   if [ -f querywork/urls-3.txt ]; then
      ccnt=`wc -l querywork/urls-3.txt | cut -f 1 -d " "`
   else
      echo "tapi_qsearch_1:  file urls-3.txt is missing"
      ccnt=0
   fi

   tcnt=`expr $acnt + $bcnt + $ccnt`
   rm tapi_qsearch_1.class

   if [ $tcnt -eq 128 ]; then
      if [ $blah -eq 0 ]; then
         echo "tapi_qsearch_1:  Test Passed"
         exit 0
      fi
   fi
else
   echo "tapi_qsearch_1:  file tapi_qsearch_1.class is missing"
fi

echo "tapi_qsearch_1:  Test Failed"
exit 1
