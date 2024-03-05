#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']
$LOAD_PATH << '.'

require 'misc'
require 'throttle-helper'

@test_results = TestResults.new("Velocity should return the correct values of throttle-id and pipelize-size")
@collection   = Collection.new(TESTENV.test_name)

def test_pipeline_size
  msg "Testing pipeline-size"
  msg "  Creating collection"
  setup

  msg "  Enqueuing a crawl-url"
  @test_results.add(enqueue_response_matches_pipeline_size(CRAWL_URL_1, 1),
                    "an enqueue to an empty collection sets the pipeline size to 1")

  msg "  Enqueuing a second crawl-url"
  @test_results.add(enqueue_response_matches_pipeline_size(CRAWL_URL_2, 2),
                    "adding the enqueue sets the pipeline size to 2")

  msg "  Enqueuing a crawl-urls node containing 2 crawl-urls"
  @test_results.add(enqueue_response_matches_pipeline_size(CRAWL_URLS, 4),
                    "adding the crawl-urls enqueue sets the pipeline size to 4")

  msg "  Enqueuing an index-atomic node containg 2 crawl-urls"
  @test_results.add(enqueue_response_matches_pipeline_size(INDEX_ATOMIC, 6),
                    "adding the index-atomic node sets the pipeline size to 6")

  msg "  Sleep 40 seconds to wait for all data to index"
  sleep 40

  msg "  Enqueuing a crawl-delete node"
  @test_results.add(enqueue_response_matches_pipeline_size(CRAWL_DELETE, 1),
                    "adding the crawl-delete node after previous data has indexed sets the pipeline size to 1")
end

def test_throttle_id
  msg "Testing throttle-id"
  msg "  Creating collection"
  setup
  msg "  Enqueuing a crawl-url"
  @test_results.add(!enqueue_response_has_throttle_id(CRAWL_URL_1),
                    "an enqueue below the enqueue-high-watermark does not result in a throttle-id")

  msg "  Sleeping 15 seconds"
  sleep 15

  msg "  Enqueuing a crawl-url"
  enqueue_response_has_throttle_id(CRAWL_URL_1.sub("dummy-a", "dummy-b"))
  msg "  Enqueuing a crawl-url"
  @test_results.add(enqueue_response_has_throttle_id(CRAWL_URL_1.sub("dummy-a", "dummy-c")),
                    "an enqueue at the enqueue-high-watermark results in a throttle-id")

  msg "  Sleeping 20 seconds"
  sleep 20
  @test_results.add(enqueue_response_matches_throttle_id(CRAWL_URL_1.sub("dummy-a", "dummy-d"), "1"),
                    "an enqueue above enqueue-low-watermark results in the same throttle-id")

  msg "  Sleeping 40 seconds to wait for all data to index"
  sleep 40

  msg "  Enqueuing a crawl-url"
  @test_results.add(!enqueue_response_has_throttle_id(CRAWL_URL_1),
                    "an enqueue below the enqueue-low-watermark removes the throttle-id")

  msg "  Enqueuing a crawl-url"
  enqueue_response_has_throttle_id(CRAWL_URL_1.sub("dummy-a", "dummy-b"))
  msg "  Enqueuing a crawl-url"
  @test_results.add(enqueue_response_has_throttle_id_greater_or_equal(CRAWL_URL_1.sub("dummy-a", "dummy-c"), "2"),
                    "an enqueue at the enqueue-high-watermark results in a new throttle-id")
end

#test_pipeline_size
test_throttle_id
@test_results.cleanup_and_exit!
