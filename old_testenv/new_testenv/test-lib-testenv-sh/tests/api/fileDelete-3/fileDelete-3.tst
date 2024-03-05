#!/bin/bash


##############################################################
#
#   Stuff that is defined for pretty much all of the apps
#   tests.
#
APPNAME=fileDelete-3

vivdata=`vivisimo_dir -d data`
thisdir=`pwd`
resultfile="querywork/$APPNAME.velocity"

newrepo="$thisdir/$APPNAME.xsl"
oldrepo="$vivdata/repository.xml"

##############################################################

passfail()
{
   if [ -f $1 ]; then
      pres=`grep -i "Uncaught Exception" $1`
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

testfile="tubersnzots_dir"

delfile1="$vivdata/$testfile"

echo "Check dir:  $delfile1"

backup_repository

repository_import -F $newrepo

run_velocity -A $APPNAME -h "filename=$delfile1"

restore_repository

zz2=`file_exists -F $delfile1`
if [ $zz2 -eq 1 ]; then
   echo "$APPNAME:  Target directory properly exists, deleting"
   delete_file -F $delfile1
   passfail $resultfile
else
   echo "$APPNAME:  Target directory improperly deleted"
fi

echo "$APPNAME:  Test Failed"

exit 1
