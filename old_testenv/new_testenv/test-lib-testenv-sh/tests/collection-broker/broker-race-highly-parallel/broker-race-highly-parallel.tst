#!/bin/bash

# Actual test with Pass/Fail criteria
$TEST_ROOT/tests/collection-broker/hammer.py
status=$?

# Cleanup: deleting all collections). Comment it out to preserve collections
#   at the end of the test
$TEST_ROOT/tests/collection-broker/hammer_cleanup.py

# Ignoring exit status from cleanup, returning exit status from test itself
exit ${status}

