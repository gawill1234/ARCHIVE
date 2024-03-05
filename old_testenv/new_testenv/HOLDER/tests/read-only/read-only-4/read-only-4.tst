#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'collection'
require 'read-only-files'

results = TestResults.new('Enable read-only with data in both the',
                          'live and staging subcollections.')

c = Collection.new('example-metadata')
c.read_only('disable') unless c.read_only_disabled?
msg "Initial run path list is:\n" + c.run_path_list.join("\n")

start_crawl = Time.now
c.crawler_start('staging')
sleep 10
while c.indexer_service_status('staging') == 'running' and
    Time.now-start_crawl < 600
  sleep 1
end
results.add(c.indexer_service_status('staging') != 'running',
            "Staging indexer is #{c.indexer_service_status('staging').inspect}.")

msg "run path list is:\n" + c.run_path_list.join("\n")

2.times do
  msg "Stop query search service and start staging crawl."
  c.vapi.search_service_stop      # Make sure we can't flip staging into live.
  c.crawler_start('staging')
  sleep 10

  # Expect both the live and staging indexers to be running.
  live_indexer = c.indexer_service_status('live')
  staging_indexer = c.indexer_service_status('staging')
  results.add(live_indexer != 'stopped',
              "Live indexer is #{live_indexer}.")
  results.add(staging_indexer != 'stopped',
              "Staging indexer is #{staging_indexer}.")

  requested = Time.now
  msg "Requesting read-only enable:"
  msg c.read_only('enable').inspect
  while c.read_only_pending? and Time.now-requested < 600
    sleep 1
  end
  results.add(c.read_only?,
              c.read_only.inspect)
  # Note that this _does_ check both live and staging.
  results.add(*fail_files_newer(c))
  msg "Restart the query search service and just wait a while."
  c.vapi.search_service_start     # Head Back toward normal...
  msg "run path list is:\n" + c.run_path_list.join("\n")
  sleep 30
  results.add(*fail_files_newer(c))
  msg "Disable read-only."
  msg c.read_only('disable').inspect

  start_crawl = Time.now
  c.crawler_start('staging')
  sleep 10
  while c.indexer_service_status('staging') == 'running' and
      Time.now-start_crawl < 600
    sleep 1
  end
  results.add(c.indexer_service_status('staging') != 'running',
              "Staging indexer is #{c.indexer_service_status('staging').inspect}.")

  msg "run path list is:\n" + c.run_path_list.join("\n")
end

results.cleanup_and_exit!
