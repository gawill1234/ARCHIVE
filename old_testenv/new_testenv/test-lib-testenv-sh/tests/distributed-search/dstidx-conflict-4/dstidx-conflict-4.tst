#/bin/bash

testname="dstidx-conflict-4"

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
echo "Basic test of conflict resolution in distributed indexing."
echo "Here, the final update actually goes to the client so that"
echo "is the update the client should keep."

echo "$TEST_ROOT/tests/distributed-search/dstidx-common5/dstidx-common5.tst $srvr1 $srvr2 $clnt -I srvr1 -I srvr2 -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common5/dstidx-common5.tst $srvr1 $srvr2 $clnt -I srvr1 -I srvr2 -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x
