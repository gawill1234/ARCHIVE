#!/bin/bash

echo $CLASSPATH

if [ -f urls-4.txt ]; then
   rm urls-4.txt
fi
if [ -f urls-5.txt ]; then
   rm urls-5.txt
fi

if [ -f tapi_qsearch_2.class ]; then
   rm tapi_qsearch_2.class
fi

if [ -f tapi_qsearch_2.java ]; then
   javac tapi_qsearch_2.java
else
   echo "tapi_qsearch_2:  file tapi_qsearch_2.java is missing"
fi

if [ -f tapi_qsearch_2.class ]; then
   rm -rf logs
   rm -rf querywork

   mkdir querywork

   java tapi_qsearch_2 --collection-name qsrch1
   blah=$?

   if [ -f querywork/urls-4.txt ]; then
      dcnt=`wc -l querywork/urls-4.txt | cut -f 1 -d " "`
   else
      echo "tapi_qsearch_2:  file urls-4.txt is missing"
      dcnt=0
   fi
   if [ -f querywork/urls-5.txt ]; then
      ecnt=`wc -l querywork/urls-5.txt | cut -f 1 -d " "`
   else
      echo "tapi_qsearch_2:  file urls-5.txt is missing"
      ecnt=0
   fi

   tcnt=`expr $dcnt + $ecnt`
   rm tapi_qsearch_2.class

   if [ $tcnt -eq 10 ]; then
      if [ $blah -eq 0 ]; then
         echo "tapi_qsearch_2:  Test Passed"
         exit 0
      fi
   fi
else
   echo "tapi_qsearch_2:  file tapi_qsearch_2.class is missing"
fi

echo "tapi_qsearch_2:  Test Failed"
exit 1
