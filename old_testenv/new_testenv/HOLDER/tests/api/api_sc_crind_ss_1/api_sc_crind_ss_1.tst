#!/bin/bash

echo $CLASSPATH

if [ -f urls.txt ]; then
   rm urls.txt
fi

if [ -f api_sc_crind_ss_1.class ]; then
   rm api_sc_crind_ss_1.class
fi

if [ -f api_sc_crind_ss_1.java ]; then
   javac api_sc_crind_ss_1.java
else
   echo "api_sc_crind_ss_1:  file api_sc_crind_ss_1.java is missing"
fi

if [ -f api_sc_crind_ss_1.class ]; then
   java api_sc_crind_ss_1 --collection-name asccss
   blah=$?

   if [ -f urls.txt ]; then
      tcnt=`wc -l urls.txt | cut -f 1 -d " "`
   else
      echo "api_sc_crind_ss_1:  file urls.txt is missing"
      tcnt=0
   fi

   rm api_sc_crind_ss_1.class

   if [ $blah -eq 0 ]; then
      if [ $tcnt -eq 46 ]; then
         echo "api_sc_crind_ss_1:  Test Passed"
         exit 0
      fi
      if [ $tcnt -eq 43 ]; then
         echo "api_sc_crind_ss_1:  Test Passed"
         exit 0
      fi
   fi
else
   echo "api_sc_crind_ss_1:  file api_sc_crind_ss_1.class is missing"
fi

echo "api_sc_crind_ss_1:  Test Failed"
exit 1
