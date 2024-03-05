#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'config'
require 'misc'
require 'cbed-utils'

CRAWL_NODES = '<crawl-urls><crawl-url enqueue-type="reenqueued" status="complete" synchronization="indexed-no-sync" url="http://vivisimo.com"><crawl-data content-type="text/plain" encoding="text">Nothing to see here. Move along.</crawl-data></crawl-url></crawl-urls>'

results = TestResults.new("Attempt to enqueue to and search the source",
                          "of a collection-broker-export-data 'move' call,",
                          "before, during and after the export.")

scol1 = Collection.new('data-export-race-5-source')
scol2 = Collection.new('data-export-race-5-source')
scol3 = Collection.new('data-export-race-5-source')
scol1.delete
tcol = Collection.new('data-export-race-5-target')
tcol.delete

sleep 1
start_iso8601 = iso8601

bc = Broker_Config.new
bc.set

bcol = base_collection
copy_collection(bcol, scol1)
msg "Source collection in place (export complete)."

# Start queries in parallel
export_id = nil
threads = []
threads[0] = Thread.new(scol1) do |scol|
  query_attempts = 0
  failures = 0
  status = nil
  while status != 'complete' and status != 'error' do
    query_attempts += 1
    begin
      scol.broker_search
    rescue
      # Search should always succeed
      failures += 1
    end
    status = export_status(scol.vapi, export_id)
  end
  [query_attempts, failures]
end

# Start enqueues in parallel
threads[1] = Thread.new(scol2) do |scol|
  enqueue_attempts = 0
  failures = 0
  status = nil
  while status != 'complete' and status != 'error' do
    enqueue_attempts += 1
    begin
      was_ro_disabled = scol.read_only_disabled?
      ok = scol.broker_enqueue_xml(CRAWL_NODES)
      if ok
        failures += 1 unless was_ro_disabled or scol.read_only_disabled?
      else
        failures += 1 if was_ro_disabled and scol.read_only_disabled?
      end
    rescue
      failures += 1 if was_ro_disabled and scol.read_only_disabled?
    end
    status = export_status(scol.vapi, export_id)
  end
  [enqueue_attempts, failures]
end

sleep 10                        # Let the queries and enqueues go for a bit

export_id = scol3.export_data(tcol.name,
                              :query => 'dog OR cat OR horse OR mule')
status = export_status(scol3.vapi, export_id)
msg "Initial export status is '#{status}'"

Thread.new(bcol.vapi) do |vapi|
  while status != 'complete' and status != 'error' do
    sleep 2
    status = export_status(vapi, export_id)
    msg "export status is '#{status}' ..."
  end
end

counts = threads.map {|t| t.value}

results.add((counts[0][0] > 1 and counts[0][1] == 0),
            "#{counts[0][0]} successful searches.",
            "#{counts[0][0]} search attempts with #{counts[0][1]} failures.")

results.add((counts[1][0] > 1 and counts[1][1] == 0),
            "#{counts[1][0]} successful enqueues.",
            "#{counts[1][0]} enqueue attempts with #{counts[1][1]} failures.")

status = export_status(scol3.vapi, export_id)
results.add((status == 'complete'),
            "Final export status is #{status}")

if status == 'complete'
  scol3.broker_search           # Failure here is an exception
  results.add(scol3.broker_enqueue_xml(CRAWL_NODES),
              "Successful search & enqueue after export complete.",
              "Enqueue to source failed after export complete.")
end

results.cleanup_and_exit!
