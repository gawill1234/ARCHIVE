#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'config'
require 'misc'
require 'cbed-utils'

results = TestResults.new("Parallel collection-broker-export-data",
                          "from a single source to different destinations.",
                          "One 'move' and one 'copy'. One should fail.")

scol1 = Collection.new('data-export-race-3-source')
scol1.delete
scol2 = Collection.new('data-export-race-3-source')
col1 = Collection.new('data-export-race-3-target-1')
col1.delete
col2 = Collection.new('data-export-race-3-target-2')
col2.delete
results.associate(scol1)
results.associate(col1)
results.associate(col2)

bcol = base_collection
vapi = bcol.vapi
copy_collection(bcol, scol1)
msg "Source collection in place (export complete)."

t1 = Thread.new { scol1.export_data(col1.name, :move => true) }
t2 = Thread.new { scol2.export_data(col2.name) }

msg "Two collection-broker-export-data calls initiated."

id1 = nil
begin
  id1 = t1.value
rescue VapiException => ex
  results.add(true, "Move export failed: #{ex}")
end

id2 = nil
begin
  id2 = t2.value
rescue VapiException => ex
  results.add(true, "Copy export failed: #{ex}")
end

# We got both exports started, watch until one completes.
msg "Export ids are #{id1.inspect} and #{id2.inspect}"

# If either export failed, the test is done and should pass.
results.cleanup_and_exit! unless id1 and id2

s1 = nil
s2 = nil
while s1 != 'complete' and s2 != 'complete' do
  sleep 15 - (Time.new.to_f % 15)
  s1 = export_status(vapi, id1) if id1
  s2 = export_status(vapi, id2) if id2
  msg "Current statuses are '#{s1}' and '#{s2}'"
  break if s1 == 'error' and s2 == 'error'
end

results.add((s1 != 'complete' or s2 != 'complete'),
            "Final statuses are '#{s1}' and '#{s2}'",
            "Final statuses are '#{s1}' and '#{s2}' (at least one should've failed)")

results.cleanup_and_exit!
