#!/bin/bash

echo $CLASSPATH

VCOLLECTION=ascclean

if [ -f firstcrawl.txt ]; then
   rm firstcrawl.txt
fi

if [ -f secondcrawl.txt ]; then
   rm secondcrawl.txt
fi

if [ -f emptycrawl.txt ]; then
   rm emptycrawl.txt
fi

if [ -f tapi_sc_clean_1.class ]; then
   rm tapi_sc_clean_1.class
fi

if [ -f tapi_sc_clean_1.java ]; then
   javac tapi_sc_clean_1.java
else
   echo "tapi_sc_clean_1:  file tapi_sc_clean_1.java is missing"
fi

sed s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml.base > ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

if [ -f tapi_sc_clean_1.class ]; then

   mkdir querywork

   java tapi_sc_clean_1 --collection-name ${VCOLLECTION}
   blah=$?

   if [ -f querywork/firstcrawl.txt ]; then
      fcnt=`wc -l querywork/firstcrawl.txt | cut -f 1 -d " "`
      echo "first count:  $fcnt"
   else
      echo "tapi_sc_clean_1:  file firstcrawl.txt is missing"
      fcnt=0
   fi
   if [ -f querywork/secondcrawl.txt ]; then
      scnt=`wc -l querywork/secondcrawl.txt | cut -f 1 -d " "`
      echo "second count:  $scnt"
   else
      echo "tapi_sc_clean_1:  file secondcrawl.txt is missing"
      scnt=0
   fi
   if [ -f querywork/emptycrawl.txt ]; then
      ecnt=`wc -l querywork/emptycrawl.txt | cut -f 1 -d " "`
      echo "empty count:  $ecnt"
   else
      ecnt=0
   fi
   tcnt=`expr $fcnt + $scnt + $ecnt`
   echo "total count:  $tcnt"

   rm tapi_sc_clean_1.class

   if [ $tcnt -eq 92 ]; then
      if [ $blah -eq 0 ]; then
         rm ${VCOLLECTION}.xml
         echo "tapi_sc_clean_1:  Test Passed"
         exit 0
      fi
   fi
else
   echo "tapi_sc_clean_1:  file tapi_sc_clean_1.class is missing"
fi

echo "tapi_sc_clean_1:  Test Failed"
exit 1
