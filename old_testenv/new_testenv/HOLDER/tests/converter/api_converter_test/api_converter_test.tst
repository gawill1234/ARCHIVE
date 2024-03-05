#!/bin/bash

ant || exit

# This is a strict match for success in a JUnit XML output file.
success='<testsuite errors="0" failures="0" '

# Check each JUnit XML output file for success, counting up failures.
failures=0
for xml in result/*.xml; do
    grep --silent "$success" $xml || failures=$((1+$failures))
done

if [ $failures == 0 ]; then
    echo Test passed.
else
    echo $failures JUnit tests failed.
    echo 'Look in "Test_Report" and/or "result" for more detail.'
    echo Test failed.
fi

exit $failures
