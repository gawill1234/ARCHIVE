#!/bin/bash

collection_name='korean-2'
test_description='Multi-threaded Korean Test'

$TEST_ROOT/lib/simple_query_result_count_test.py $0 "$test_description" $collection_name
