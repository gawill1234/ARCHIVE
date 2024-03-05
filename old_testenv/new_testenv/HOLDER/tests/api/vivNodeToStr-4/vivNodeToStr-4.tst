#!/bin/bash


##############################################################
#
#   Stuff that is defined for pretty much all of the apps
#   tests.
#
APPNAME=vivNodeToStr-4

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

putfile1="$thisdir/nodes.xml"
delfile1="$vivdata/nodes.xml"

put_file -F $putfile1 -D $vivdata

backup_repository

new_repository -F $newrepo

run_velocity -A $APPNAME

restore_repository

delete_file -F $delfile1

passfail $resultfile

echo "$APPNAME:  Test Failed"

exit 1
