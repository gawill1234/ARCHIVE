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
if [ -f urls-4.txt ]; then
   rm urls-4.txt
fi
if [ -f urls-5.txt ]; then
   rm urls-5.txt
fi

if [ -f tapi_sc_conf_fs_1.class ]; then
   rm tapi_sc_conf_fs_1.class
fi

if [ -f tapi_sc_conf_fs_1.java ]; then
   javac tapi_sc_conf_fs_1.java
else
   echo "tapi_sc_conf_fs_1:  file tapi_sc_conf_fs_1.java is missing"
fi

if [ -f tapi_sc_conf_fs_1.class ]; then
   rm -rf logs
   rm -rf querywork

   mkdir querywork

   java tapi_sc_conf_fs_1 --collection-name cnffs1
   blah=$?

   if [ -f querywork/urls-1.txt ]; then
      acnt=`wc -l querywork/urls-1.txt | cut -f 1 -d " "`
   else
      echo "tapi_sc_conf_fs_1:  file urls-1.txt is missing"
      acnt=0
   fi
   if [ -f querywork/urls-2.txt ]; then
      bcnt=`wc -l querywork/urls-2.txt | cut -f 1 -d " "`
   else
      echo "tapi_sc_conf_fs_1:  file urls-2.txt is missing"
      bcnt=0
   fi
   if [ -f querywork/urls-3.txt ]; then
      ccnt=`wc -l querywork/urls-3.txt | cut -f 1 -d " "`
   else
      echo "tapi_sc_conf_fs_1:  file urls-3.txt is missing"
      ccnt=0
   fi
   if [ -f querywork/urls-4.txt ]; then
      dcnt=`wc -l querywork/urls-4.txt | cut -f 1 -d " "`
   else
      echo "tapi_sc_conf_fs_1:  file urls-4.txt is missing"
      dcnt=0
   fi
   if [ -f querywork/urls-5.txt ]; then
      ecnt=`wc -l querywork/urls-5.txt | cut -f 1 -d " "`
   else
      echo "tapi_sc_conf_fs_1:  file urls-5.txt is missing"
      ecnt=0
   fi

   tcnt=`expr $acnt + $bcnt + $ccnt + $dcnt + $ecnt`
   rm tapi_sc_conf_fs_1.class

   if [ $tcnt -eq 230 ]; then
      if [ $blah -eq 0 ]; then
         echo "tapi_sc_conf_fs_1:  Test Passed"
         exit 0
      else
         echo "Queries correct but some other aspect of java part failed"
      fi
   else
      echo "Expected count of 230, got $tcnt"
   fi
else
   echo "tapi_sc_conf_fs_1:  file tapi_sc_conf_fs_1.class is missing"
fi

echo "tapi_sc_conf_fs_1:  Test Failed"
exit 1
