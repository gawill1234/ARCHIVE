#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'oracle-ship-collection'

test_results = TestResults.new("Crawl an oracle database using a plaintext password")

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
collection = OracleShipCollection.new(vapi, Collection.new(TESTENV.test_name))
test_results.associate(collection)

xml = collection.xml
xml.xpath("//crawler/call-function[@name='vse-crawler-seed-database-key']/with[@name='password']").
    first.content = "mustang5"
collection.set_xml(xml)

collection.crawl

test_results.add_number_equals(359, collection.index_n_docs, "indexed document")

collection.search("Arizona")
test_results.add_number_equals(3, collection.document_count, "'Arizona' document")

collection.search("bismarck")
test_results.add_number_equals(2, collection.document_count, "'bismarck' document")

collection.search("arizona")
test_results.add_number_equals(3, collection.document_count, "'arizona' document")

collection.search("Blücher")
test_results.add(collection.results_empty?, "'Blücher' returned no documents",
                 "'Blücher' returned #{collection.document_count} instead of 0")

collection.search("Arizona Battleship")
test_results.add_number_equals(3, collection.document_count, "'Arizona Battleship' document")

test_results.cleanup_and_exit!
