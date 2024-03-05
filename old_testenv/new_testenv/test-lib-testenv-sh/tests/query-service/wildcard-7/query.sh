#!/bin/bash

ID=$1
VCOLLECTION=$2
uniquer=""

i=0
while [ $i -lt $ID ]; do
   i=`expr $i + 1`
   uniquer="$uniquer"@
done

rm -f querywork/query-*.$ID

run_wildcard_query()
{
   query=$2
   #fname=querywork/query-$1.$ID
   fname=querywork/query-$1.$$

   #run_query -S $VCOLLECTION -O $fname -Q "$query"$uniquer -n 1
   #last=`xsltproc total.xsl $fname`
   last=`xsltproc --stringparam mynode query-result-count $TEST_ROOT/utils/xsl/velocity_api.xsl $fname`
   if [ -z "$last" ]; then
      last=0
   else
      if [ "$last" == "" ]; then
         last=0
      fi
   fi

   run_query -S $VCOLLECTION -O $fname -Q "$query"$uniquer -n 1
   #num=`xsltproc total.xsl $fname`
   num=`xsltproc --stringparam mynode query-result-count $TEST_ROOT/utils/xsl/velocity_api.xsl $fname`
   if [ -z "$num" ]; then
      echo "Query [$query] failed (num not set)"
      #exit 1
   else
      if [ "$num" == "" ]; then
         echo "Query [$query] failed (num is blank)"
         #exit 1
      else
         echo "LAST:  $last"
         echo "NUM:  $num"
         echo "Query [$query] returned (num)[$num] results after returning (last)[$last]"
         if [ $last -gt $num ]; then
	    exit 1
         fi
      fi
   fi
}

run_all_queries()
{
   now=`date +%s`
   run_wildcard_query 1 '"this* *game*"'
   run_wildcard_query 2 '*fuck*'
   run_wildcard_query 3 '*test* NOTWITHIN test'
   run_wildcard_query 4 '*y?st*'
   run_wildcard_query 5 'gam* theor* *vegas'
   then=`date +%s`
   echo "**** QUERIES TOOK: `expr $then - $now` seconds"
}

if [ "$3" == --final ]; then
   for i in query_cmp_files/query-* ; do
	cp $i querywork/`basename $i`.$$
   done
   run_all_queries
   exit 0
fi

while [ 1 ];do
   run_all_queries
done

exit 0
