#!/bin/bash

test1()
{

   ##
   #   This value is global.  Please update it.
   #
   casecount=`expr $casecount + 1`
   ##

   echo "test1: Begin"
   ##
   #   This does simple queries and checks that the query results
   #   are correct (match compare file)
   #   It returns 0 if it passes, 1 if it fails.
   #
   simple_search.tst -H $SHOST -C $VCOLLECTION -Q <query> -T $VCOLLECTION
   ##

   ##
   #   Capture the result of the query
   #
   xx=$?
   ##

   ##
   #   Use the result to issue a case pass/fail
   #
   if [ $xx -ne 0 ]; then
      echo "test1: Case Failed"
   else
      echo "test1: Case Passed"
   fi
   ##

   ##
   #   This value is global.  Please update it.
   #   This updates the global test pass/fail result
   #
   results=`expr $results + $xx`
   ##

}

test2()
{

   casecount=`expr $casecount + 1`
   echo "test2: Begin"
   simple_search.tst -H $SHOST -C $VCOLLECTION -Q Arizona+Battleship -T $VCOLLECTION
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test2: Case Failed"
   else
      echo "test2: Case Passed"
   fi

   results=`expr $results + $xx`

}

test3()
{

   casecount=`expr $casecount + 1`
   echo "test3: Begin"
   simple_search.tst -H $SHOST -C $VCOLLECTION -Q bismarck -T $VCOLLECTION
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test3: Case Failed"
   else
      echo "test3: Case Passed"
   fi

   results=`expr $results + $xx`

}

test4()
{

   casecount=`expr $casecount + 1`
   echo "test4: Begin"
   simple_search.tst -H $SHOST -C $VCOLLECTION -Q arizona -T $VCOLLECTION
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test4: Case Failed"
   else
      echo "test4: Case Passed"
   fi

   results=`expr $results + $xx`

}

test5()
{

   casecount=`expr $casecount + 1`
   echo "test5: Begin"
   simple_search.tst -H $SHOST -C $VCOLLECTION -Q Blücher -T $VCOLLECTION
   xx=$?
   if [ $xx -ne 0 ]; then
      echo "test5: Case Failed"
   else
      echo "test5: Case Passed"
   fi

   results=`expr $results + $xx`

}

#####################################################################

