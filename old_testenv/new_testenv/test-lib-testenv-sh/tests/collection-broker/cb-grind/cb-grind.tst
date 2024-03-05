#!/bin/bash

$TEST_ROOT/tests/collection-broker/tunable.py &

list=(*-results.xml)
$TEST_ROOT/lib/multi_search.py --collections="${list[*]%-results.xml}"
