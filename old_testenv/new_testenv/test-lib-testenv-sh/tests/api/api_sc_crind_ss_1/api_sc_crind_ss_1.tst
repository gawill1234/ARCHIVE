#!/bin/bash

echo $CLASSPATH

VCOLLECTION=asccss

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

sed s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml.base > ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

if [ -f api_sc_crind_ss_1.class ]; then
   java api_sc_crind_ss_1 --collection-name ${VCOLLECTION}
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
         rm ${VCOLLECTION}.xml
         echo "api_sc_crind_ss_1:  Test Passed"
         exit 0
      fi
      if [ $tcnt -eq 43 ]; then
         rm ${VCOLLECTION}.xml
         echo "api_sc_crind_ss_1:  Test Passed"
         exit 0
      fi
   fi
else
   echo "api_sc_crind_ss_1:  file api_sc_crind_ss_1.class is missing"
fi

echo "api_sc_crind_ss_1:  Test Failed"
exit 1
