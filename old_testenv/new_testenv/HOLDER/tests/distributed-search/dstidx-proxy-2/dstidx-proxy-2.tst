#/bin/bash

testname="dstidx-proxy-2"

if [ $# -eq 0 ]; then
   echo $VIVHOST
   srvr="-S $VIVHOST"
   clnt="-C $VIVHOST"
   oclnt="-O $VIVHOST"
else
   srvr="-S $1"
   clnt="-C $2"
   oclnt="-O $3"
fi

echo "Test $testname"
echo "Test of proxied client where a file is deleted from the"
echo "server in a distributed index scenario."

echo "$TEST_ROOT/tests/distributed-search/dstidx-common2/dstidx-common2.tst $srvr $clnt $oclnt -d -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common2/dstidx-common2.tst $srvr $clnt $oclnt -d -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x
