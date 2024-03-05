#!/bin/bash


##############################################################
#
#   Stuff that is defined for pretty much all of the apps
#   tests.
#
APPNAME=fileDelete-2

vivdata=`vivisimo_dir -d data`
thisdir=`pwd`
resultfile="querywork/$APPNAME.velocity"

newrepo="$thisdir/$APPNAME.xsl"
oldrepo="$vivdata/repository.xml"

##############################################################

passfail()
{
   if [ -f $1 ]; then
      pres=`grep -i "TEST PASSED" $1`
      if [[ $pres == "" ]]; then
         echo ""
         echo "$APPNAME:  Test Failed"
         exit 1
      fi

      fres=`grep -i "TEST FAILED" $1`
      if [[ $fres == "" ]]; then
         echo ""
         echo "$APPNAME:  Test Passed"
         exit 0
      fi
   else
      echo ""
      echo "Result file missing"
      echo "$APPNAME:  Test Failed"
      exit 1
   fi

}

##############################################################
#
#   The running of the test ...
#

testfile="tubersnzots"

echo "This is a testfile put here by:  $APPNAME" > $testfile

delfile1="$vivdata/$testfile"
putfile1="$thisdir/$testfile"

echo "Check file:  $delfile1"

put_file -F $putfile1 -D $vivdata

zz=`file_exists -F $delfile1`

if [ $zz -eq 1 ]; then

   backup_repository

   repository_import -F $newrepo

   run_velocity -A $APPNAME -h "filename=$delfile1"

   restore_repository

   rm $testfile
   zz2=`file_exists -F $delfile1`
   if [ $zz2 -eq 0 ]; then
      passfail $resultfile
   else
      echo "$APPNAME:  Target file not deleted correctly"
      delete_file -F $delfile1
   fi

fi

echo "$APPNAME:  Test Failed"

exit 1
