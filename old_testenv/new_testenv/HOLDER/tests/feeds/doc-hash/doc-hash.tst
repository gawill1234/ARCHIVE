#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'
$LOAD_PATH << '.'

require 'misc'
require 'collection'
require 'feed-helper'
require 'doc-hash-helper'
require 'vse-key-enqueues'

@test_results = TestResults.new("Given that a collection is configured to produce activities",
                                "When I add documents to the collection",
                                "Then the activities will contain a document-key-hash that matches the indexer-provided hash")
@collection   = Collection.new(TESTENV.test_name)

setup
enable_activity_feed
enqueue_vse_key_nodes

check_documents(:number => 18)

@test_results.cleanup_and_exit!
