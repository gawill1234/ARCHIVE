#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'config'
require 'misc'
require 'cbed-utils'

results = TestResults.new("Parallel collection-broker-export-data 'copy'",
                          "from a single source to a single destination.",
                          "One export should fail.")

col = Collection.new('data-export-race-1-target')
col.delete
vapi = col.vapi

sleep 1
start_iso8601 = iso8601

bc = Broker_Config.new
bc.set

bcol1 = base_collection
bcol2 = Collection.new(bcol1.name)

t1 = Thread.new { bcol1.export_data(col.name) }
t2 = Thread.new { bcol2.export_data(col.name) }

msg "Two collection-broker-export-data calls initiated."

id1 = t1.value
id2 = t2.value

msg "Export ids are #{id1} #{id2}"

s1 = nil
s2 = nil
while s1 != 'complete' and s2 != 'complete' do
  sleep 15 - (Time.new.to_f % 15)
  s1 = export_status(vapi, id1)
  s2 = export_status(vapi, id2)
  msg "Current statuses are '#{s1}' and '#{s2}'"
  if s1 == 'error' and s2 == 'error'
    raise "Both exports ended with an error status."
  end
end

results.add(((s1 == 'complete' or s2 == 'complete') and s1 != s2),
            "Final statuses are '#{s1}' and '#{s2}'",
            "Final statuses are '#{s1}' and '#{s2}' (one should've failed)")

results.cleanup_and_exit!
