#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'config'
require 'misc'
require 'cbed-utils'

CRAWL_NODES = '<crawl-urls><crawl-url enqueue-type="reenqueued" status="complete" synchronization="indexed-no-sync" url="http://vivisimo.com"><crawl-data content-type="text/plain" encoding="text">Nothing to see here. Move along.</crawl-data></crawl-url></crawl-urls>'

def report_action(results, action, status)
  results.add((status == 'complete'),
              "Successful #{action} with export status of '#{status}'")
end

results = TestResults.new("Attempt to delete collections during",
                          "a collection-broker-export-data call,",
                          "then do many stop/starts during the export.")

col = Collection.new('data-export-race-4-target')
col.delete
vapi = col.vapi

sleep 1
start_iso8601 = iso8601

bc = Broker_Config.new
bc.set

bcol = base_collection
bcol.broker_start
export_id = bcol.export_data(col.name, :query => 'dog OR cat OR horse OR mule')
msg "Initial export status is '#{export_status(vapi, export_id)}'"


results.add((not col.delete_no_wait),
            "Attempt to delete the target collection.")
results.add((not bcol.delete_no_wait),
            "Attempt to delete the source collection.")

status = nil
passes = 0
while status != 'complete' and status != 'error' do
  passes += 1

  # Just pound away with stops and starts.
  bcol.stop_no_wait
  col.stop_no_wait

  bcol.crawler_start
  begin
    # may not exist yet...
    col.crawler_start
  rescue
  end

  status = export_status(vapi, export_id)
end

results.add((passes > 1),
            "#{passes} stop/start attempts made.")

results.add((status == 'complete'),
            "Final export status is #{status}")

results.cleanup_and_exit!
