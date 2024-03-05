#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'oracle-ship-collection'

test_results = TestResults.new("Crawl an oracle database by specifying a view.",
                               "NOTE: This is a pretty basic test, there are",
                               "more sophisticated tests in the tests/indexer",
                               "directory that test metadata fields of an",
                               "oracle crawl: search-by-fast-indexed-metadata,",
                               "search-by-indexed-metadata and",
                               "search-by-indeed-metadata-with-default-output")

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
collection = OracleShipCollection.new(vapi, Collection.new(TESTENV.test_name))
test_results.associate(collection)

collection.crawl

test_results.add_number_equals(359, collection.index_n_docs, "indexed document")

collection.search("Arizona")
test_results.add_number_equals(3, collection.document_count, "'Arizona' document")

collection.search("bismarck")
test_results.add_number_equals(2, collection.document_count, "'bismarck' document")

collection.search("arizona")
test_results.add_number_equals(3, collection.document_count, "'arizona' document")

collection.search("NO_RESULTS")
test_results.add(collection.results_empty?, "'NO_RESULTS' returned no documents",
                 "'NO_RESULTS' returned #{collection.document_count} instead of 0")

collection.search("Arizona Battleship")
test_results.add_number_equals(3, collection.document_count, "'Arizona Battleship' document")

test_results.cleanup_and_exit!
