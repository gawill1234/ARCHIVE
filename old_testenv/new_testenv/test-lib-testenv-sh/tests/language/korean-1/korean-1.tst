#!/bin/bash

collection_name='korean-1'
test_description='Korean tokenizer sanity test'

$TEST_ROOT/lib/simple_query_result_count_test.py $0 "$test_description" $collection_name
