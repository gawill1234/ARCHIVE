#/bin/bash

testname="dstidx-error-1"

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
echo "Test of error recovery, kill the client crawler periodically"

echo "$TEST_ROOT/tests/distributed-search/dstidx-common/dstidx-common.tst $srvr $clnt -E clnt_crl -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common/dstidx-common.tst $srvr $clnt -E clnt_crl -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x