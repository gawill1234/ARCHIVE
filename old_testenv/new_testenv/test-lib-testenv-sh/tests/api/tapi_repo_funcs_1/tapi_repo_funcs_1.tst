#!/bin/bash

echo $CLASSPATH

VCOLLECTION=repotest

if [ -f urls.txt ]; then
   rm urls.txt
fi

if [ -f tapi_repo_funcs_1.class ]; then
   rm tapi_repo_funcs_1.class
fi

if [ -f tapi_repo_funcs_1.java ]; then
   javac tapi_repo_funcs_1.java
else
   echo "tapi_repo_funcs_1:  file tapi_repo_funcs_1.java is missing"
fi

sed s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml.base > ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

if [ -f tapi_repo_funcs_1.class ]; then
   java tapi_repo_funcs_1 --collection-name ${VCOLLECTION}
   blah=$?

   if [ -f urls.txt ]; then
      scnt=`wc -l urls.txt | cut -f 1 -d " "`
      rm urls.txt
   else
      echo "tapi_repo_funcs_1:  file urls.txt is missing"
      scnt=0
   fi

   rm tapi_repo_funcs_1.class

else
   echo "tapi_repo_funcs_1:  file tapi_repo_funcs_1.class is missing"
fi

if [ $blah -eq 0 ]; then
   if [ $scnt -eq 46 ]; then
      rm ${VCOLLECTION}.xml
      echo "tapi_repo_funcs_1:  Test Passed"
      exit 0
   fi
   if [ $scnt -eq 43 ]; then
      rm ${VCOLLECTION}.xml
      echo "tapi_repo_funcs_1:  Test Passed"
      exit 0
   fi
fi

echo "tapi_repo_funcs_1:  Test Failed"
exit 1
