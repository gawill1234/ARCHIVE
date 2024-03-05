#!/bin/bash

tfile=`basename $0`
gt="generalTest"
targetDir="$TEST_ROOT/tests/generics"

export CLASSPATH=$CLASSPATH:$targetDir
#echo $CLASSPATH

MyCollection="binning-2"

tname=`echo $tfile | sed "s/\.tst//"`

#cname="$gt.class"
cname="$targetDir/$gt.class"
jname="$targetDir/$gt.java"

if [ ! -e $cname ]; then
   if [ -e $jname ]; then
      #javac $jname -d .
      javac $jname -d $TEST_ROOT/tests/generics
   else
      echo "$tname:  file $jname is missing"
   fi
fi

if [ -e $cname ]; then

   repository_delete -t syntax -n custom

   #
   #   Since the binning setup is related soley to the collection, binning
   #   queries should work.  However, the basic metadata stuff needs changes
   #   in the source and the custom sytax needs to be created; neither of which
   #   have been done for this part.  Therefore, binning queries should yield
   #   results while metadata queries should not.
   #
   java $gt -tname $tname -collection $MyCollection -noteardown -noupdate -queryfile TEST_QUERIES_PRE
   first=$?

   #
   #   Additional steps needed to get metadata queries to work
   #   correctly.
   #
   #   Add SHIP_TYPE as a recognized syntax item.  (python)
   #
   repository_update -F ship_type.syntax.xml -N
   #
   #   Update the collection SOURCE to use the SHIP_TYPE field.  (python)
   #
   repository_update -F binning-2.src.xml -N

   #
   #   Do the metadata and binning field queries.  (java)
   #   Now, the syntax and sources have been modified so both metadata and
   #   binning queries should yield results.
   #
   java $gt -tname $tname -collection $MyCollection -nosetup -queryfile TEST_QUERIES
   second=$?
   blah=`expr $first + $second`

   #
   #   Delete the syntax changes so the do not impact other tests.
   #
   repository_delete -t syntax -n custom

   if [ $blah -eq 0 ]; then
      echo "$tname:  Test Passed"
      rm -rf logs querywork
      exit $blah
   fi

else
   echo "$tname:  file $cname is missing"
fi

echo "$tname:  Test Failed"
exit 1
