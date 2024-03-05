#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-always-on"
   VCOLLECTION1="crawler-always-on-samba"
#
#   Each of these basically represents a snapshot of the 
#   refreshed collection with different things done to
#   it.
#
   VCOLLECTION2="crawler-always-on-samba-initial"
   VCOLLECTION3="crawler-always-on-samba-middle"
   VCOLLECTION4="crawler-always-on-samba-final"
   VCOLLECTION5="crawler-always-on-samba-empty"
   VCOLLECTION6="crawler-always-on-samba-new"
   VCOLLECTION7="crawler-always-on-samba-changed"
   VCOLLECTION8="crawler-always-on-samba-bigdel"
   VCOLLECTION9="crawler-always-on-samba-bigadd"

   DESCRIPTION="Repeated refresh crawl of samba collection"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

stablelist="/testenv/samba_test_data/refresh-stress/stable"
BASE="/testenv/samba_test_data/refresh-stress/working"
workingdir=""

getfrom="/testenv/samba_test_data/refresh-stress/new-refresh-files"
copyto=""

flushtestdir()
{
   echo "CLEAR TEST DIRECTORY"

   echo $BASE
   export TMPDIR=$BASE
   workingdir=`mktemp -d -t $VCOLLECTION1.XXXX`
   copyto="$workingdir"
   chmod 755 $copyto

   smbspace=`echo $workingdir | sed s/testenv/testfiles/`

   collectionspace="sed -e 's;REPLACE__ME;$smbspace;g'"
   cat refrsmbbasexml | eval $collectionspace > $VCOLLECTION1.xml
}


#####################################################################
test_header $VCOLLECTION $DESCRIPTION

speed=$1
if [ "$speed" == "" ]; then
   speed="slow"
fi

echo "SPEED:  $speed"

rm -f querywork/samba-result

getsetopts $*

cleanup $SHOST $VCOLLECTION1 $VUSER $VPW

files=`ls $stablelist`
oldresults=0

#########################################################
#
#   Initial crawl of populated space
#
flushtestdir
echo "-- crawler-always-on:  initialize directory, $workingdir"
rm -f $workingdir/*
for fls in $files; do
   filename=`basename $fls`
   echo "--  crawler-always-on:  adding $workingdir/$filename"
   cp -R $stablelist/$filename $workingdir/$filename
done

echo "Make inaccessible directories ..."
mkdir -p $workingdir/noexec
mkdir -p $workingdir/noperm
mkdir -p $workingdir/noread
   
chmod 444 $workingdir/noexec
chmod 000 $workingdir/noperm
chmod 111 $workingdir/noread

echo "... done"

setup $SHOST $VCOLLECTION1 $VUSER $VPW
cp $VCOLLECTION2.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1

echo "-- crawler-always-on:  Basic refresh  ###############################"
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Basic crawl refresh failed            #"
   echo "###########################################"
   oldresults=$results
fi
#########################################################

#########################################################
#
#   Straight delete mode
#   Delete files from the collection and refresh.
#
echo "-- crawler-always-on:  Deletion refresh  #############################"
for fls in $files; do
   filename=`basename $fls`
   echo "--  crawler-always-on:  deleting $workingdir/$filename"
   rm -f $workingdir/$filename
   if [ "$speed" == "slow" ]; then
      echo "--  crawler-always-on:  refreshing crawl"
      refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
      wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   fi
done
if [ "$speed" == "fast" ]; then
   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
fi
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION5.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Deletion refresh failed               #"
   echo "###########################################"
   oldresults=$results
   exit 1
fi
#########################################################

#########################################################
#
#   Straight add mode
#   Add files to the collection and refresh.
#
echo "-- crawler-always-on:  Addition refresh  #############################"
for fls in $files; do
   filename=`basename $fls`
   echo "--  crawler-always-on:  adding $workingdir/$filename"
   cp $stablelist/$filename $workingdir/$filename
   if [ "$speed" == "slow" ]; then
      echo "--  crawler-always-on:  refreshing crawl"
      refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
      wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   fi
done
if [ "$speed" == "fast" ]; then
   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
fi
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION2.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Addition refresh failed               #"
   echo "###########################################"
   oldresults=$results
fi
#########################################################


#########################################################
#
#   Add files that were never there before
#
echo "-- crawler-always-on:  Addition refresh 2  #########################"
number=1
while [ $number -le 50 ]; do
   suffix=".$number"
   files=`ls $getfrom/*\.$number`
   for zz in $files; do
      myfile=`basename $zz $suffix`
      copyfile=`basename $myfile`
      echo "--  crawler-always-on:  adding $copyto/$copyfile"
      cp $zz $copyto/$copyfile
   done
   if [ "$speed" == "slow" ]; then
      refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
      wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   fi
   number=`expr $number + 1`
done
if [ "$speed" == "fast" ]; then
   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
fi
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION6.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Addition refresh 2 failed             #"
   echo "###########################################"
   oldresults=$results
fi
#########################################################

#########################################################
#
#   Change some of the existing files.
#
echo "-- crawler-always-on:  Updated files refresh  ####################"
while [ $number -le 53 ]; do
   suffix=".$number"
   files=`ls $getfrom/*\.$number`
   for zz in $files; do
      myfile=`basename $zz $suffix`
      copyfile=`basename $myfile`
      echo "--  crawler-always-on:  adding $copyto/$copyfile"
      cp $zz $copyto/$copyfile
   done
   if [ "$speed" == "slow" ]; then
      refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
      wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
   fi
   number=`expr $number + 1`
done
if [ "$speed" == "fast" ]; then
   refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
   wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
fi
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION7.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Updated files refresh failed          #"
   echo "###########################################"
   oldresults=$results
fi
#########################################################

#########################################################
#
#   Big delete
#
echo "-- crawler-always-on:  Big delete refresh   ######################"
number=1
while [ $number -le 50 ]; do
   suffix=".$number"
   files=`ls $getfrom/*\.$number`
   for zz in $files; do
      myfile=`basename $zz $suffix`
      copyfile=`basename $myfile`
      echo "--  crawler-always-on:  removing $copyto/$copyfile"
      rm -f $copyto/$copyfile
   done
   number=`expr $number + 1`
done
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION8.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Big delete refresh failed             #"
   echo "###########################################"
   oldresults=$results
fi
#########################################################

#########################################################
#
#   Big update
#
echo "-- crawler-always-on:  Big add refresh  ##########################"
number=1
while [ $number -le 50 ]; do
   suffix=".$number"
   files=`ls $getfrom/*\.$number`
   for zz in $files; do
      myfile=`basename $zz $suffix`
      copyfile=`basename $myfile`
      echo "--  crawler-always-on:  adding $copyto/$copyfile"
      cp $zz $copyto/$copyfile
   done
   number=`expr $number + 1`
done
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION3.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Big add refresh failed                #"
   echo "###########################################"
   oldresults=$results
fi
#########################################################

#########################################################
#
#   Big delete with on the fly file actions
#
echo "-- crawler-always-on:  Deletion on the fly refresh  ##############"
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
number=1
while [ $number -le 50 ]; do
   suffix=".$number"
   files=`ls $getfrom/*\.$number`
   for zz in $files; do
      myfile=`basename $zz $suffix`
      copyfile=`basename $myfile`
      echo "--  crawler-always-on:  removing $copyto/$copyfile"
      rm -f $copyto/$copyfile
      sleep 1
   done
   number=`expr $number + 1`
done
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
#########################################################

#########################################################
#
#   Big update with on the fly file actions
#
echo "-- crawler-always-on:  Addition on the fly refresh  ##############"
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
number=1
while [ $number -le 50 ]; do
   suffix=".$number"
   files=`ls $getfrom/*\.$number`
   for zz in $files; do
      myfile=`basename $zz $suffix`
      copyfile=`basename $myfile`
      echo "--  crawler-always-on:  adding $copyto/$copyfile"
      cp $zz $copyto/$copyfile
      sleep 1
   done
   number=`expr $number + 1`
done
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
#########################################################

#
#   Final refresh on clean system to see that we got 
#   everything
#
echo "-- crawler-always-on:  Final refresh  ############################"
refresh_crawl -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
merge_index -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW &
wait_for_idle -C $VCOLLECTION1 -H $SHOST -U $VUSER -P $VPW
cp $VCOLLECTION4.xml.stats $VCOLLECTION1.xml.stats
crawl_check_nv $SHOST $VCOLLECTION1
if [ $results -ne $oldresults ]; then
   echo "###########################################"
   echo "#   Final refresh failed                  #"
   echo "###########################################"
   oldresults=$results
fi

echo "$DESCRIPTION: exit($results)"
if [ $results -eq 0 ]; then
   echo "PASSED" > querywork/samba-result
   chmod 755 $workingdir/noexec
   chmod 755 $workingdir/noperm
   chmod 755 $workingdir/noread
   rm -rf $workingdir
else
   echo "FAILED" > querywork/samba-result
fi
exit $results

