#!/bin/bash

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


