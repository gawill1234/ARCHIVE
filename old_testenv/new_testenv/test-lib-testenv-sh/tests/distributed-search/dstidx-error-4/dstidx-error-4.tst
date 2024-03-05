#/bin/bash

testname="dstidx-error-4"

if [ $# -eq 0 ]; then
   echo $VIVHOST
   srvr="-S $VIVHOST"
   clnt="-C $VIVHOST"
else
   srvr="-S $1"
   clnt=""

   shift

   while [ -n "$*" ]
   do
      clnt="$clnt -C $1"
      shift
   done
fi

echo "Test $testname"
echo "Test of error recovery, kill the server indexer"
echo "and the server crawler periodically"

echo "$TEST_ROOT/tests/distributed-search/dstidx-common/dstidx-common.tst $srvr $clnt -E clnt_idx -E srvr_idx -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common/dstidx-common.tst $srvr $clnt -E srvr_crl -E srvr_idx -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x