#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'testenv'
require 'config'
require 'misc'
require 'evault-sim'

if TESTENV.velocity.host =~ /testbed/
  puts "This test is too large for our testbed machines"
  exit 2
end

start_iso8601 = iso8601

step = []

bc = Broker_Config.new.set
sim = EVaultSim.new
sim.set('/EVaultSim/server/name', File.basename($0))
sim.set('/EVaultSim/server/n-users', 5000)        # total cols
sim.set('/EVaultSim/server/max-active-users', 100) # parallel cols
sim.set('/EVaultSim/n-enqueuers', 100)             # total threads
sim.set('/EVaultSim/server/max-documents', 100)   # docs per col
sim.set('/EVaultSim/batch-size', 5)               # docs per enqueue
sim.set('/EVaultSim/content-size', 500)           # words per doc
# (no updates & deletes)
sim.set('/EVaultSim/vse-config/vse-index/vse-index-option[@name="cache-mb"]', 50) # MB Cache
# We're doing a single run with validation, no need to persist to disk.
sim.set('/EVaultSim/run-dict-validation', true)
sim.set('/EVaultSim/persist-validation-to-disk', false)
sim.set('/EVaultSim/generate-deletes-percent', 0.0)
step << sim.run

end_iso8601 = iso8601

msg "System Report from #{start_iso8601} to #{end_iso8601}"
step << system("$TEST_ROOT/lib/system_report.py #{start_iso8601} #{end_iso8601}")
msg "End of System Report"

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
