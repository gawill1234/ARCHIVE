#!/bin/bash

while [ 1 ]; do
   refresh_crawl -C $1 -H $2 -U $3 -P $4
   sleep 3
   touch /testenv/test_data/spec_tests/smoke_test/searchdocs/*
done
