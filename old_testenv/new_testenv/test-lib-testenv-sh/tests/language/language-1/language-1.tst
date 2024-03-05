#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="language-1"
   DESCRIPTION="Simple crawl of docs of different languages"

###
###

WORKINGDIR="querywork"

langfunc()
{

   cd $WORKINGDIR

   casecount=`expr $casecount + 1`
   lres=0
   LANGUAGE="$1"

   echo ""
   echo "#############"
   echo "LANGUAGE:  $LANGUAGE"
   echo ""

   get_bin -C $VCOLLECTION -B "lang:$LANGUAGE"

   RSLTFILE="bin.lang..$LANGUAGE.uri.rslt"
   XMLFILE="bin.lang..$LANGUAGE.xml.rslt"
   CMPFILE="bin.lang..$LANGUAGE.uri.cmp"
   DIFFFILE="bin.lang..$LANGUAGE.uri.diff"

   if [ -f $XMLFILE ]; then
      sort_query_urls -F $XMLFILE > $RSLTFILE
      if [ -f $RSLTFILE ]; then
         diff -B $RSLTFILE ../query_cmp_files/$CMPFILE > $DIFFFILE
         lres=$?
      else
         lres=1
      fi
   else
      lres=1
   fi
   if [ $lres -ne 0 ]; then
      echo "$LANGUAGE file checks failed"
      results=`expr $results + 1`
   else
      echo "$LANGUAGE file checks passed"
   fi

   echo "#############"

   cd ..
}

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh


#####################################################################

test_header $VCOLLECTION $DESCRIPTION

sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_USER/${VIV_SAMBA_LINUX_USER}/g ${VCOLLECTION}.xml
sed -i s/VIV_SAMBA_LINUX_PASSWORD/${VIV_SAMBA_LINUX_PASSWORD}/g ${VCOLLECTION}.xml
sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${VCOLLECTION}.xml

source $TEST_ROOT/lib/run_std_setup.sh

crawl_check $SHOST $VCOLLECTION

for file in query_cmp_files/qry*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

for file in query_cmp_files/bin*
do
  echo "Updating file ${file}"
  sed -i s/VIV_SAMBA_LINUX_SERVER/${VIV_SAMBA_LINUX_SERVER}/g ${file}
  sed -i s,VIV_SAMBA_LINUX_SHARE,${VIV_SAMBA_LINUX_SHARE},g ${file}
done

#
#   function basic_query_test
#   args are test number, host, collection, query string
#
basic_query_test 1 $SHOST $VCOLLECTION ""

langfunc italian
langfunc thai
langfunc spanish
langfunc swedish
langfunc korean
langfunc portuguese
langfunc japanese
langfunc german
langfunc french
langfunc english
langfunc dutch
langfunc chinese
langfunc catalan
langfunc unknown

rm ${VCOLLECTION}.xml
rm query_cmp_files/qry*
rm query_cmp_files/bin*

source $TEST_ROOT/lib/run_std_results.sh
