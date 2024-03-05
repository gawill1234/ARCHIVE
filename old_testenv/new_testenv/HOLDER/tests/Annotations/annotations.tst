#!/bin/bash

ant || exit

# This is a strict match for success in a JUnit XML output file.
success='<testsuite errors="0" failures="0" '

# Check each JUnit XML output file for success, counting up failures.
failures=0
for xml in result/*.xml; do
    grep --silent "$success" $xml || failures=$((1+$failures))
done

# Try to get any failure messages into the stdout log file.
grep -E '<(error|failure) message=' result/*.xml
messages=$?

if [ $failures == 0 ] && [ $messages != 0 ]; then
    echo Test passed.
    exit 0
fi

echo $failures JUnit tests failed.
echo 'Look in "Test_Report" and/or "result" for more detail.'
echo Test failed.
exit 1
