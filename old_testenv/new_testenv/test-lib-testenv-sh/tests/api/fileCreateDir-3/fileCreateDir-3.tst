#!/bin/bash


##############################################################
#
#   Stuff that is defined for pretty much all of the apps
#   tests.
#
APPNAME=fileCreateDir-3

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

vivcgi=`vivisimo_dir`

#
#   File created by the xsl and file:create-directory
#
vivcgi=$vivcgi/www/cgi-bin/tubersnzots

backup_repository

new_repository -F $newrepo

run_velocity -A $APPNAME

restore_repository

#
#   Check for the created directory
#
zz=`file_exists -F $vivcgi`

#
#   Delete the created file unconditionally.  Make sure
#   it does not hang around and interfere with other tests.
#
delete_file -F $vivcgi

if [ $zz -eq 1 ]; then

   echo "$APPNAME:  proceeding with xsl output check"
   passfail $resultfile

fi

echo "$APPNAME:  Test Failed"

exit 1
