#!/bin/bash

diff_match_counts()
{

   casecount=`expr $casecount + 1`
   results=`expr $results + 1`

   #
   #   Need to update this to take into account binning
   #   files that begin with "bin.".
   #
   file1="query_cmp_files/qry.$1.xml.cmp"
   file2="querywork/qry.$1.xml.rslt"

   match1="querywork/mtch.$1.cmp"
   match2="querywork/mtch.$1.rslt"

   matchdiff="querywork/mtch.$1.diff"

   get_match_counts -Q $1 -F $file1 > $match1
   get_match_counts -Q $1 -F $file2 > $match2

   diff $match1 $match2 > /dev/null
   diffval=$?

   if [ $diffval -eq 0 ]; then
      echo "Match count for query $1 is OK"
      results=`expr $results - 1`
   else
      echo "Match count for query $1 differ"
      get_url_matches -Q $1 -F $file1 > $matchdiff
      get_url_matches -Q $1 -F $file2 >> $matchdiff
   fi

   return
}

diff_titles()
{

   casecount=`expr $casecount + 1`
   results=`expr $results + 1`

   #
   #   Need to update this to take into account binning
   #   files that begin with "bin.".
   #
   file1="query_cmp_files/qry.$1.xml.cmp"
   file2="querywork/qry.$1.xml.rslt"

   match1="querywork/ttl.$1.cmp"
   match2="querywork/ttl.$1.rslt"

   matchdiff="querywork/ttl.$1.diff"

   content_titles -Q $1 -F $file1 > $match1
   content_titles -Q $1 -F $file2 > $match2

   diff $match1 $match2 > /dev/null
   diffval=$?

   if [ $diffval -eq 0 ]; then
      echo "Title comparison for query $1 is OK"
      results=`expr $results - 1`
   else
      echo "Title comparison for query $1 differ"
   fi

   return
}

basic_query_test()
{

   casecount=`expr $casecount + 1`
   echo "test $1: Begin"
   if [ "$5" == "windows" ];then
      simple_search -H $2 -C $3 -Q "$4" -T $3 -w
   else
      simple_search -H $2 -C $3 -Q "$4" -T $3
   fi
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test $1: Case Failed"
   else
      echo "test $1: Case Passed"
   fi

   results=`expr $results + $xx`

}

basic_binning_test()
{

   casecount=`expr $casecount + 1`
   echo "test $1: Begin"
   if [ "$5" == "windows" ];then
      simple_binning -H $2 -C $3 -Q "$4" -T $3 -w
   else
      simple_binning -H $2 -C $3 -Q "$4" -T $3
   fi
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test $1: Case Failed"
   else
      echo "test $1: Case Passed"
   fi

   results=`expr $results + $xx`

}

full_bin_test()
{

   casecount=`expr $casecount + 1`
   echo "test $1: Begin"
   check_bin -H $2 -C $3 -B "$4"
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test $1: Case Failed"
   else
      echo "test $1: Case Passed"
   fi

   results=`expr $results + $xx`

}


