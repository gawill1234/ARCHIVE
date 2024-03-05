#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="del_dup_refresh"
   DESCRIPTION="Delete and refresh using duplicate files"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

stablepath="/testenv/samba_test_data/del_dup/stable"
BASE="/testenv/samba_test_data/del_dup/working"
testpath=""
NEWDIR=""

r[1]="REVIEW_207.pdf"
D[1]="REVIEW_208.pdf"
r[2]="REVIEW_287.pdf"
D[2]="REVIEW_288.pdf"
r[3]="REVIEW_2026.pdf"
D[3]="REVIEW_2027.pdf"
r[4]="REVIEW_2041.pdf"
D[4]="REVIEW_2042.pdf"
r[5]="REVIEW_2089.pdf"
D[5]="REVIEW_2090.pdf"
r[6]="REVIEW_2154.pdf"
D[6]="REVIEW_2155.pdf"
r[7]="REVIEW_2158.pdf"
D[7]="REVIEW_2159.pdf"
r[8]="REVIEW_2160.pdf"
D[8]="REVIEW_2161.pdf"
r[9]="REVIEW_2179.pdf"
D[9]="REVIEW_2180.pdf"
r[10]="REVIEW_2191.pdf"
D[10]="REVIEW_2192.pdf"
r[11]="REVIEW_2198.pdf"
D[11]="REVIEW_2199.pdf"
r[12]="REVIEW_2226.pdf"
D[12]="REVIEW_2227.pdf"
r[13]="REVIEW_2263.pdf"
D[13]="REVIEW_2264.pdf"
r[14]="REVIEW_2276.pdf"
D[14]="REVIEW_2277.pdf"
r[15]="REVIEW_2309.pdf"
D[15]="REVIEW_2310.pdf"
r[16]="REVIEW_2330.pdf"
D[16]="REVIEW_2331.pdf"
r[17]="REVIEW_2457.pdf"
D[17]="REVIEW_2458.pdf"
r[18]="REVIEW_2476.pdf"
D[18]="REVIEW_2477.pdf"
r[19]="REVIEW_2488.pdf"
D[19]="REVIEW_2489.pdf"

reality="${r[1]} ${r[2]} ${r[3]} ${r[4]} ${r[5]} ${r[6]} ${r[7]} ${r[8]} ${r[9]} ${r[10]} ${r[11]} ${r[12]} ${r[13]} ${r[14]} ${r[15]} ${r[16]} ${r[17]} ${r[18]} ${r[19]}"
reality2="${r[2]} ${r[4]} ${r[5]} ${r[6]} ${r[8]} ${r[9]} ${r[12]} ${r[15]}"

duplicity="${D[1]} ${D[2]} ${D[3]} ${D[4]} ${D[5]} ${D[6]} ${D[7]} ${D[8]} ${D[9]} ${D[10]} ${D[11]} ${D[12]} ${D[13]} ${D[14]} ${D[15]} ${D[16]} ${D[17]} ${D[18]} ${D[19]}"
duplicity2="${D[2]} ${D[4]} ${D[5]} ${D[6]} ${D[8]} ${D[9]} ${D[12]} ${D[15]}"

flushtestdir()
{
   echo "CLEAR TEST DIRECTORY"

   echo $BASE
   export TMPDIR=$BASE
   testpath=`mktemp -d -t $VCOLLECTION.XXXX`
   chmod 755 $testpath

   smbspace=`echo $testpath | sed s,testenv,${VIV_SAMBA_LINUX_SHARE},`

   collectionspace="sed -e 's;REPLACE__ME;$smbspace;g'"
   cat basexml | eval $collectionspace > $VCOLLECTION.xml
   sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/ ${VCOLLECTION}.xml
   sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/ ${VCOLLECTION}.xml
   sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/ ${VCOLLECTION}.xml

}


removealloriginals()
{
   for item in $reality; do
      rm $testpath/$item
   done
}

putinallduplicates()
{
   for item in $duplicity; do
      cp $stablepath/$item $testpath/$item
   done
}

testinitialize()
{

   echo "INITIALIZE TEST DIRECTORY"

   for item in $reality; do
      cp $stablepath/$item $testpath/$item
   done

   for item in $duplicity2; do
      cp $stablepath/$item $testpath/$item
   done
}

resetinplace()
{

   for item in $reality; do
      if [ -f $testpath/$item ]; then
         touch $testpath/$item
      fi
   done

   for item in $duplicity2; do
      if [ -f $testpath/$item ]; then
         touch $testpath/$item
      fi
   done
}

deletereallist()
{

   for item in $reality2; do
      rm $testpath/$item
   done
}

addorremoveone()
{

   fn=`genrand -m 1 -M 22`

   if [ $fn -gt 19 ]; then
      echo "IN PLACE FILE RESET"
      resetinplace
   else
   fname=${D[$fn]}
      if [ -f $testpath/$fname ]; then
         echo "REMOVING:  $fname"
         rm $testpath/$fname
      else
         echo "ADDING:  $fname"
         cp $stablepath/$fname $testpath/$fname
      fi
   fi
}

check_url_count()
{
   casecount=`expr $casecount + 1`
   run_query -C $VCOLLECTION -Q "" --nodups
   xx=`grep -i url query_results | grep pdf | wc -l`

   if [ $xx -ne 19 ]; then
      echo "Wrong number of urls in query:  $xx found, wanted 19"
      results=`expr $result + 1`
   else
      echo "Url count is correct"
      rm query_results
   fi
}

lengthytestloop()
{
i=0
MAXLOOP=10

   while [ $i -lt $MAXLOOP ]; do
      i=`expr $i + 1`
      echo "TEST LOOP ITERATION:  $i"
      addorremoveone
      refresh_crawl -C $VCOLLECTION
      wait_for_idle -C $VCOLLECTION
      check_url_count
      if [ $results -gt 0 ]; then
         echo "del_dup_refresh:  Test Failed"
         source $TEST_ROOT/lib/run_std_results.sh
      fi
   done

}

pdfcheck()
{
   casecount=`expr $casecount + 1`
   run_query -C $VCOLLECTION -Q ""
   grep -i url query_results | grep pdf | cut -d '/' -f 9 | sort | sed "s/\"//g" > test_pdfs
   grep -i url query_cmp_files/qry..xml.cmp | grep pdf | cut -d '/' -f 9 | sort | sed "s/\"//g" > known_pdfs

   diff test_pdfs known_pdfs > pdf_diffs
   res=$?

   if [ $res -ne 0 ]; then
      echo "Query returned different pdf files than expected"
      results=`expr $results + 1`
   fi
}

test_header $VCOLLECTION $DESCRIPTION

if [ -f $stablepath/${D[2]} ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "mount /testenv"
   echo "Then rerun the test"
   echo "del_dup_refresh: Test Failed"
   exit 1
fi

for file in query_cmp_files/qry*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

flushtestdir
testinitialize

source $TEST_ROOT/lib/run_std_setup.sh

check_url_count

deletereallist

refresh_crawl -C $VCOLLECTION

wait_for_idle -C $VCOLLECTION

check_url_count

echo "RESET TEST DIRECTORY"
testinitialize

echo "SINGLE FILE ADD/REMOVE AND REFRESH"

lengthytestloop

echo "ALL ORIGINAL FILES REMOVED"
echo "ONLY DUPLICATES ARE BEING RECRAWLED"

putinallduplicates
removealloriginals

refresh_crawl -C $VCOLLECTION
wait_for_idle -C $VCOLLECTION
check_url_count

crawl_check_nv $SHOST $VCOLLECTION

echo "CHECKING FOR EXPECTED FILES"
pdfcheck

if [ $results -eq 0 ]; then
   rm -rf $testpath
fi

rm ${VCOLLECTION}.xml
rm basexml
rm query_cmp_files/qry*

source $TEST_ROOT/lib/run_std_results.sh
