#!/bin/bash

#####################################################################

###
#   Global stuff
###
   
   source $TEST_ROOT/lib/global_setting.sh

   VCOLLECTION="refresh-stress"
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
   echo "mount nfs share, then rerun the test."
   echo "refresh-stress: Test Failed"
   exit 1
fi

mkdir -p querywork

./refresh-stress-oracle.sh $speed > querywork/oracle_output &
rsoracle=$!
echo "ORACLE:  $rsoracle"

./refresh-stress-postgres.sh $speed > querywork/postgres_output &
rspostgres=$!
echo "POSTGRES:  $rspostgres"

./refresh-stress-sharepoint.sh $speed 1> querywork/sharepoint_output 2> querywork/sharepoint_output_err &
rssharepoint=$!
echo "SHAREPOINT:  $rssharepoint"

./refresh-stress-samba.sh $speed 1> querywork/samba_output 2> querywork/samba_output_err&
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
   delete_collection -C refresh-stress-samba
   delete_collection -C refresh-stress-oracle
   delete_collection -C refresh-stress-postgres
   delete_collection -C refresh-stress-sharepoint
   echo "refresh-stress:  Test Passed"
   exit 0
else
   echo "oracle refresh:  exit($oraexit)"
   echo "postgres refresh:  exit($pgrexit)"
   echo "sharepoint refresh:  exit($shpexit)"
   echo "samba refresh:  exit($smbexit)"
   echo "refresh-stress:  Test Failed"
   stop_indexing -C refresh-stress-samba
   stop_indexing -C refresh-stress-oracle
   stop_indexing -C refresh-stress-postgres
   stop_indexing -C refresh-stress-sharepoint
fi

exit 1
