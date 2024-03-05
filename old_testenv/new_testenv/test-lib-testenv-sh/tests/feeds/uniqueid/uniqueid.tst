#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'
$LOAD_PATH << '.'

require 'misc'
require 'collection'
require 'feed-helper'
require 'uniqueid-helper'
require 'vse-key-enqueues'

@test_results = TestResults.new("Given that a collection is configured to produce activities",
                                "When I add documents to the collection",
                                "Then the activities will contain a unique id")
@collection   = Collection.new(TESTENV.test_name)

setup
enable_activity_feed
enqueue_vse_key_nodes
enqueue_url_with_multiple_crawl_datas

check_documents(:number => 22)

@test_results.cleanup_and_exit!
