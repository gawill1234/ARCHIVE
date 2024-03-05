#!/bin/bash

echo $CLASSPATH
VCOLLECTION=qsrch1

if [ -f tapi_qsearch_3.class ]; then
   rm tapi_qsearch_3.class
fi

if [ -f tapi_qsearch_3.java ]; then
   javac tapi_qsearch_3.java
else
   echo "tapi_qsearch_3:  file tapi_qsearch_3.java is missing"
fi

sed s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml.base > ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

if [ -f tapi_qsearch_3.class ]; then
   rm -rf logs
   rm -rf querywork

   java tapi_qsearch_3 --collection-name ${VCOLLECTION}
   blah=$?

   rm tapi_qsearch_3.class

   if [ $blah -eq 0 ]; then
      rm ${VCOLLECTION}.xml
      echo "tapi_qsearch_3:  Test Passed"
      exit 0
   fi
else
   echo "tapi_qsearch_3:  file tapi_qsearch_3.class is missing"
fi

echo "tapi_qsearch_3:  Test Failed"
exit 1
