#!/bin/bash

$TEST_ROOT/lib/ruby/lib/misc.rb

export REMOVECOLLECTIONS=true

$TEST_ROOT/tests/collection-broker/small-sequential-retry-search.py "$@"
