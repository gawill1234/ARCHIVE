#!/bin/bash

[ "$VIVWIPE" == True ] && $TEST_ROOT/lib/restore_velocity_defaults.py

$TEST_ROOT/tests/collection-broker/config.rb maximum-collections=0

$TEST_ROOT/tests/collection-broker/tunable.py --collection-size=10 \
                                              --collections=20000 \
                                              --enqueue-collections=100 \
                                              --enqueues=1
