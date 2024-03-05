#!/bin/bash

echo $CLASSPATH

if [ -f ssrunning.txt ]; then
   rm ssrunning.txt
fi

if [ -f ssrunning2.txt ]; then
   rm ssrunning2.txt
fi

if [ -f ssrunning3.txt ]; then
   rm ssrunning3.txt
fi

if [ -f ssnotrunning.txt ]; then
   rm ssnotrunning.txt
fi

if [ -f ssnotrunning2.txt ]; then
   rm ssnotrunning2.txt
fi

if [ -f tapi_ss_funcs_1.class ]; then
   rm tapi_ss_funcs_1.class
fi

if [ -f tapi_ss_funcs_1.java ]; then
   javac tapi_ss_funcs_1.java
else
   echo "tapi_ss_funcs_1:  file tapi_ss_funcs_1.java is missing"
fi

if [ -f tapi_ss_funcs_1.class ]; then

   mkdir querywork

   java tapi_ss_funcs_1 --collection-name asssqry
   blah=$?

   if [ -f querywork/ssrunning.txt ]; then
      acnt=`wc -l querywork/ssrunning.txt | cut -f 1 -d " "`
   else
      echo "tapi_ss_funcs_1:  file ssrunning.txt is missing"
      acnt=0
   fi
   if [ -f querywork/ssrunning2.txt ]; then
      bcnt=`wc -l querywork/ssrunning2.txt | cut -f 1 -d " "`
   else
      echo "tapi_ss_funcs_1:  file ssrunning2.txt is missing"
      bcnt=0
   fi
   if [ -f querywork/ssrunning3.txt ]; then
      ccnt=`wc -l querywork/ssrunning3.txt | cut -f 1 -d " "`
   else
      echo "tapi_ss_funcs_1:  file ssrunning3.txt is missing"
      ccnt=0
   fi
   if [ -f querywork/ssnotrunning.txt ]; then
      dcnt=`wc -l querywork/ssnotrunning.txt | cut -f 1 -d " "`
   else
      dcnt=0
   fi
   if [ -f querywork/ssnotrunning2.txt ]; then
      ecnt=`wc -l querywork/ssnotrunning2.txt | cut -f 1 -d " "`
   else
      ecnt=0
   fi
   tcnt=`expr $acnt + $bcnt + $ccnt + $dcnt + $ecnt`

   rm tapi_ss_funcs_1.class

   if [ $tcnt -eq 138 ]; then
      if [ $blah -eq 0 ]; then
         echo "tapi_ss_funcs_1:  Test Passed"
         exit 0
      fi
   else
      echo "Expected 138 results, got $tcnt"
   fi
else
   echo "tapi_ss_funcs_1:  file tapi_ss_funcs_1.class is missing"
fi

echo "tapi_ss_funcs_1:  Test Failed"
exit 1
