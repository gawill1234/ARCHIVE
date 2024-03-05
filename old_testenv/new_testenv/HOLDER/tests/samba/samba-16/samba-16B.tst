#!/bin/bash

tfile=`basename $0`
gt="generalTest"
targetDir="$TEST_ROOT/tests/generics"

export CLASSPATH=$CLASSPATH:$targetDir
#echo $CLASSPATH

MyCollection="samba-16"

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
   java $gt -tname $tname -collection $MyCollection -noteardown -queryfile TEST_QUERIES -errors 3
   first=$?

   merge_index -C $MyCollection

   #
   #   Do the metadata and binning field queries.  (java)
   #   Now, the syntax and sources have been modified so both metadata and
   #   binning queries should yield results.
   #
   java $gt -tname $tname -collection $MyCollection -nosetup -queryfile TEST_QUERIES -errors 3
   second=$?
   blah=`expr $first + $second`

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
