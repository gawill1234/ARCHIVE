#!/bin/bash

#####################################################################

###
#   Global stuff
###

   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="8238-2"
   DESCRIPTION="Negative pending crawl check"

###
###

export VIVERRIGN="COLLECTION_SERVICE_SERVICE_TERMINATED"
export VIVSRVERRIGN="indexer"

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################

stablepath="/testenv/samba_test_data/8238/stable"
BASE="/testenv/samba_test_data/8238/working"
NEWDIR=""
A=""
B=""
C=""
D=""

#
#   This rigamarole is because all runs of this test generally
#   operate in the same space.  Doing this means one copy will
#   not step on another if two or more copies are running at once.
#
createtestdir()
{
   echo "CREATE TEST DIRECTORY"

   echo $BASE
   export TMPDIR=$BASE
   NEWDIR=`mktemp -d -t $VCOLLECTION.XXXX`
   chmod 755 $NEWDIR
   A="$NEWDIR/A"
   B="$NEWDIR/A/B"
   C="$NEWDIR/A/B/C"
   D="$NEWDIR/A/B/C/D"

   smbspace=`echo $A | sed s/testenv/testfiles/`

   collectionspace="sed -e 's;REPLACE__ME;$smbspace;g'"
   cat basexml | eval $collectionspace > $VCOLLECTION.xml

}

testinitialize()
{

   echo "INITIALIZE TEST DIRECTORY"

   rm -rf $A
   mkdir -p $NEWDIR/A/B/C/D

   cp $stablepath/ONE.pdf $A
   cp $stablepath/TWO.pdf $B
   cp $stablepath/FOUR.pdf $D

}

movefourout()
{
   rm -f $D/FOUR.pdf
}

movethreefourin()
{
   cp $stablepath/THREE.pdf $C
   cp $stablepath/FOUR.pdf $D
}

test_header $VCOLLECTION $DESCRIPTION

version60

if [ -f $stablepath/ONE.pdf ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "refresh-stress: Test Failed"
   exit 1
fi

createtestdir

count=0
MAXITER=5

while [ $count -lt $MAXITER ]; do
   count=`expr $count + 1`
   testinitialize
   source $TEST_ROOT/lib/run_std_setup.sh

   cmpl=`crawl_outputs -C $VCOLLECTION`
   pndg=`crawl_pending -C $VCOLLECTION`

   #
   #   assume failure until checked
   #
   results=`expr $results + 2`
   if [ $cmpl -eq 7 ]; then
      results=`expr $results - 1`
   else
      echo "$VCOLLECTION,crawl: Unexpected crawl complete count, expected 7, got $cmpl"
   fi
   if [ $pndg -eq 0 ]; then
      results=`expr $results - 1`
   else
      echo "$VCOLLECTION,crawl: Unexpected crawl pending count, expected 0, got $pndg"
   fi
   if [ $results -ne 0 ]; then
      source $TEST_ROOT/lib/run_std_results.sh
   fi

   movefourout

   refresh_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION

   cmpl=`crawl_outputs -C $VCOLLECTION`
   pndg=`crawl_pending -C $VCOLLECTION`

   #
   #   assume failure until checked
   #
   results=`expr $results + 2`
   if [ $cmpl -eq 6 ]; then
      results=`expr $results - 1`
   else
      echo "$VCOLLECTION,r1: Unexpected crawl complete count, expected 6, got $cmpl"
   fi
   if [ $pndg -eq 0 ]; then
      results=`expr $results - 1`
   else
      echo "$VCOLLECTION,r1: Unexpected crawl pending count, expected 0, got $pndg"
   fi
   if [ $results -ne 0 ]; then
      source $TEST_ROOT/lib/run_std_results.sh
   fi

   movethreefourin

   refresh_crawl -C $VCOLLECTION
   wait_for_idle -C $VCOLLECTION

   cmpl=`crawl_outputs -C $VCOLLECTION`
   pndg=`crawl_pending -C $VCOLLECTION`

   #
   #   assume failure until checked
   #
   results=`expr $results + 2`
   if [ $cmpl -eq 8 ]; then
      results=`expr $results - 1`
   else
      echo "$VCOLLECTION,r2: Unexpected crawl complete count, expected 8, got $cmpl"
   fi
   if [ $pndg -eq 0 ]; then
      results=`expr $results - 1`
   else
      echo "$VCOLLECTION,r2: Unexpected crawl pending count, expected 0, got $pndg"
   fi
   if [ $results -ne 0 ]; then
      source $TEST_ROOT/lib/run_std_results.sh
   fi
done

if [ $results -eq 0 ]; then
   rm -rf $NEWDIR
fi

source $TEST_ROOT/lib/run_std_results.sh
