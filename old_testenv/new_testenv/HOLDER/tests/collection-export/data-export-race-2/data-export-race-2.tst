#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'config'
require 'misc'
require 'cbed-utils'

results = TestResults.new("Parallel collection-broker-export-data 'copy'",
                          "from a single source to different destinations.")

col1 = Collection.new('data-export-race-2-target-1')
col1.delete
col2 = Collection.new('data-export-race-2-target-2')
col2.delete
vapi = col1.vapi

sleep 1
start_iso8601 = iso8601

bc = Broker_Config.new
bc.set

bcol1 = base_collection
bcol2 = Collection.new(bcol1.name)

t1 = Thread.new { bcol1.export_data(col1.name) }
t2 = Thread.new { bcol2.export_data(col2.name) }

msg "Two collection-broker-export-data calls initiated."

id1 = t1.value
id2 = t2.value

msg "Export ids are #{id1} #{id2}"

s1 = nil
s2 = nil
while (s1 != 'complete' and s1 != 'error') or
      (s2 != 'complete' and s2 != 'error') do
  sleep 15 - (Time.new.to_f % 15)
  s1 = export_status(vapi, id1)
  s2 = export_status(vapi, id2)
  msg "Current statuses are '#{s1}' and '#{s2}'"
end

results.add((s1 == 'complete' and s2 == 'complete'),
            "Final statuses are '#{s1}' and '#{s2}'",
            "Final statuses are '#{s1}' and '#{s2}' (both should be 'complete')")

results.cleanup_and_exit!
