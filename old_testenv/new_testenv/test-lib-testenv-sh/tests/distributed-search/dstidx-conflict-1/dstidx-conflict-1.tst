#/bin/bash

testname="dstidx-conflict-1"

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

echo "$TEST_ROOT/tests/distributed-search/dstidx-common4/dstidx-common4.tst $srvr1 $srvr2 $clnt -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common4/dstidx-common4.tst $srvr1 $srvr2 $clnt -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x
