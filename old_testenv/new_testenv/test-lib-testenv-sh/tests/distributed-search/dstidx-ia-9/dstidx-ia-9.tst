#/bin/bash

testname="dstidx-ia-9"

if [ $# -eq 0 ]; then
   echo $VIVHOST
   srvr1="-S $VIVHOST"
   srvr2="-S $VIVHOST"
   clnt="-C $VIVHOST"
else
   srvr1="-S $1"
   shift

   srvr2="-S $1"
   shift

   while [ -n "$*" ]
   do
      clnt="$clnt -C $1"
      shift
   done
fi

echo "Test $testname"
echo "Test of atomic indexing.  Just assure that using an index-atomic"
echo "on all servers with a mixed bag of audit log use does not cause"
echo "a failure."

echo "$TEST_ROOT/tests/distributed-search/dstidx-common3/dstidx-common3.tst $srvr1 $srvr2 $clnt -I srvr1 -I srvr2 -A clnt -A srvr2 -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common3/dstidx-common3.tst $srvr1 $srvr2 $clnt -I srvr1 -I srvr2 -A clnt -A srvr2 -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x
