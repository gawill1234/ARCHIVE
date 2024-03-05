#!/bin/bash


##############################################################
#
#   Stuff that is defined for pretty much all of the apps
#   tests.
#
APPNAME=japdap
export VIVLOWVERSION="7.0"

vivdata=`vivisimo_dir -d data`
thisdir=`pwd`
resultfile="querywork/$APPNAME.velocity"

#newrepo="$thisdir/$APPNAME.xsl"
#oldrepo="$vivdata/repository.xml"

##############################################################

passfail()
{
   if [ -f $1 ]; then
      pres=`grep -i "success" $1`
      if [[ $pres == "success" ]]; then
         echo ""
         echo "$APPNAME:  Test Passed"
         exit 0
      else
         echo "Expected success string not found"
      fi
   else
      echo "Result file missing"
   fi

   echo ""
   echo "$APPNAME:  Test Failed"
   exit 1

}

##############################################################
#
#   The running of the test ...
#

#backup_repository

repository_import -F $APPNAME.xsl -N

run_velocity -A $APPNAME

sleep 2

#restore_repository
repository_delete  -t application -n japdap

passfail $resultfile

echo "$APPNAME:  Test Failed"

exit 1
