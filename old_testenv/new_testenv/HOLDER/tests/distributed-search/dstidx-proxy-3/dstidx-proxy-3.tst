#/bin/bash

testname="dstidx-proxy-3"

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
echo "Test of proxied client where a file is added to the"
echo "server in a distributed index scenario."

echo "$TEST_ROOT/tests/distributed-search/dstidx-common2/dstidx-common2.tst $srvr $clnt $oclnt -a -T $testname"

$TEST_ROOT/tests/distributed-search/dstidx-common2/dstidx-common2.tst $srvr $clnt $oclnt -a -T $testname

x=$?

if [ $x == 0 ]; then
   echo "$testname:  Test Passed"
else
   echo "$testname:  Test Failed"
fi

exit $x
