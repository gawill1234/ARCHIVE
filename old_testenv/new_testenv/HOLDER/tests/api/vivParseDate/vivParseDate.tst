#!/bin/bash

##############################################################
#
#   Stuff that is defined for pretty much all of the apps
#   tests.
#
APPNAME=vivParseDate

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

putfile1="$thisdir/sheet.xsl"
putfile2="$thisdir/vivParseDate.xml"

#delfile1="$vivdata/sheet.xsl"
delfile2="$vivdata/vivParseDate.xml"

put_file -F $putfile1 -D $vivdata
put_file -F $putfile2 -D $vivdata

repository_import -F $newrepo

run_velocity -A $APPNAME

repository_delete --elemtype application --elemname $APPNAME

#delete_file -F $delfile1
delete_file -F $delfile2

passfail $resultfile

echo "$APPNAME:  Test Failed"

exit 1
