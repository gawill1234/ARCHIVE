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

results = TestResults.new("Attempt to enqueue to and search the target",
                          "of a collection-broker-export-data call,",
                          "during the export.")

col = Collection.new('data-export-race-4-target')
col.delete
vapi = col.vapi

sleep 1
start_iso8601 = iso8601

bc = Broker_Config.new
bc.set

bcol = base_collection
export_id = bcol.export_data(col.name, :query => 'dog OR cat OR horse OR mule')
msg "Initial export status is '#{export_status(vapi, export_id)}'"

status = nil
passes = 0
while status != 'complete' and status != 'error' do
  passes += 1
  begin
    vapi.query_search(:sources => col.name)
    report_action(results, 'search', export_status(vapi, export_id))
  rescue
  end

  begin
    col.enqueue_xml(CRAWL_NODES)
    report_action(results, 'enqueue', export_status(vapi, export_id))
  rescue
  end
  status = export_status(vapi, export_id)
end

results.add((passes > 1),
            "#{passes} search and enqueue attempts made.")

results.add((status == 'complete'),
            "Final export status is #{status}")

if status == 'complete'
  vapi.query_search(:sources => col.name)
  col.enqueue_xml(CRAWL_NODES)
  results.add(true, "Successful search & enqueue after export complete.")
end

results.cleanup_and_exit!
