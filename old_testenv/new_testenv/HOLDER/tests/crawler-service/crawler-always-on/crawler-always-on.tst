#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="crawler-always-on"
   DESCRIPTION="Refresh with concurrent queries"

###
###

source $TEST_ROOT/lib/lib_func.sh
source $TEST_ROOT/lib/lib_query.sh

#####################################################################
test_header $VCOLLECTION $DESCRIPTION

speed=$1
if [ "$speed" == "" ]; then
   speed="slow"
fi

echo "SPEED:  $speed"

if [ -f /testenv/samba_test_data/refresh-stress/stable/us_doi.pdf ]; then
   echo "/testenv is mounted.  We can continue"
else
   echo "/testenv directory is not mounted."
   echo "Create a local directory name /testenv.  Then, as root, do:"
   echo "mount -t nfs testbed5.test.vivisimo.com:/virtual2/data /testenv"
   echo "Then rerun the test"
   echo "refresh-stress: Test Failed"
   exit 1
fi

mkdir -p querywork

./crawler-always-on-oracle.sh $speed > querywork/oracle_output &
rsoracle=$!
echo "ORACLE:  $rsoracle"

./crawler-always-on-postgres.sh $speed > querywork/postgres_output &
rspostgres=$!
echo "POSTGRES:  $rspostgres"

./crawler-always-on-sharepoint.sh $speed > querywork/sharepoint_output &
rssharepoint=$!
echo "SHAREPOINT:  $rssharepoint"

./crawler-always-on-samba.sh $speed 1> querywork/samba_output 2> querywork/samba_output_err&
rssamba=$!
echo "SAMBA:  $rssamba"

sleep 2

echo "Wait for test parts to complete.  This will be awhile"
echo "Even if you said fast, this will still take 25 minutes"
echo "Waiting ..."
wait $rsoracle
oraexit=$?
wait $rspostgres
pgrexit=$?
wait $rssharepoint
shpexit=$?
wait $rssamba
smbexit=$?

finalstat=`expr $oraexit + $pgrexit + $shpexit + $smbexit`

if [ $finalstat -eq 0 ]; then
   delete_collection -C crawler-always-on-samba
   delete_collection -C crawler-always-on-oracle
   delete_collection -C crawler-always-on-postgres
   delete_collection -C crawler-always-on-sharepoint
   echo "crawler-always-on:  Test Passed"
   exit 0
else
   echo "oracle refresh:  exit($oraexit)"
   echo "postgres refresh:  exit($pgrexit)"
   echo "sharepoint refresh:  exit($shpexit)"
   echo "samba refresh:  exit($smbexit)"
   echo "crawler-always-on:  Test Failed"
   stop_indexing -C crawler-always-on-samba
   stop_indexing -C crawler-always-on-oracle
   stop_indexing -C crawler-always-on-postgres
   stop_indexing -C crawler-always-on-sharepoint
fi

exit 1
