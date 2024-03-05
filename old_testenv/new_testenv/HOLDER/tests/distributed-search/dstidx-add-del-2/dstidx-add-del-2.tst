#/bin/bash

testname="dstidx-add-del-2"

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
echo "Test of collection adds and delete to a set of distributed"
echo "collections.  How clients and servers react when one or the"
echo "other of a client or server disappears and reappears."
echo "This test uses index atomic enqueues."

echo "$TEST_ROOT/tests/distributed-search/dstidx-common6/dstidx-common6.tst $srvr1 $srvr2 $clnt -I srvr1 -I srvr2 -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common6/dstidx-common6.tst $srvr1 $srvr2 $clnt -I srvr1 -I srvr2 -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x
