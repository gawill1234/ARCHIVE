#!/bin/bash

# Do very small scale versions of our main tests.
# These correspond to broker-1, broker-2, broker-3 and broker-4
# We really expect these to pass.

$TEST_ROOT/lib/ruby/lib/misc.rb

CBHOME=$TEST_ROOT/tests/collection-broker
export REMOVECOLLECTIONS=true

$CBHOME/small-sequential-retry-search.py 10         || exit
$CBHOME/tunable.py -c 2                             || exit
$CBHOME/small-sequential-aggressive-search.py 10    || exit
$CBHOME/small-sequential-tuned-wait.py 10           || exit
