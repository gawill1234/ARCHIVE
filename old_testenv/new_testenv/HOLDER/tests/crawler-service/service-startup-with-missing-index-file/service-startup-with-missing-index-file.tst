#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'timeout'

results = TestResults.new(
  'Test for bug 28471: SYMC EV - Collection service leaking memory',
  'This test verifies that the crawler eventually gives up launching the',
  'indexer when the indexer fails to start.',
)
results.need_system_report = false

def create_collection_with_failing_indexer(results)
  # Create a collection to work with.
  collection = Collection.new(TESTENV.test_name)
  results.associate(collection)

  collection.delete
  collection.create('example-metadata')

  # Start the crawler so we have an index file to work with.
  collection.crawler_start

  # Stop the indexer so we can delete an index file.
  Timeout::timeout(60) { collection.wait_until_idle }
  collection.indexer_stop

  # Delete an index file to cause the indexer to fail.
  live, staging = collection.crawl_path_list
  status_node = collection.status
  index_fname = status_node.xpath("//vse-index-file[1]/@name").first

  gronk = Gronk.new
  gronk.rm_file("#{live}/#{index_fname}")

  # Keep the crawler alive long enough to give up trying to connect to
  # the indexer.
  collection.set_crawl_options({:idle_running_time => 45}, {})

  collection
end

collection = create_collection_with_failing_indexer(results)

# Start the crawler and wait for it to fail.
collection.crawler_start
Timeout::timeout(60) { collection.wait_until_stopped }

# Detect the crawler error state.
status_node = collection.status
error_msg = status_node.xpath("//crawler-status/@error").first.to_s
results.add_matches(/indexer service failed/, error_msg, :what => "error message")

results.cleanup_and_exit!(true)
