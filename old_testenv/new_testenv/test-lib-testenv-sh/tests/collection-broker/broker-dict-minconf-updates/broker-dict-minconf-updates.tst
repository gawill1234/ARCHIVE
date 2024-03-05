#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'testenv'
require 'config'
require 'misc'
require 'evault-sim'

start_iso8601 = iso8601

step = []

bc = Broker_Config.new.set
sim = EVaultSim.new
sim.set('/EVaultSim/server/name', File.basename($0))
sim.set('/EVaultSim/server/n-users', 1)          # total cols
sim.set('/EVaultSim/server/max-active-users', 1) # parallel cols
sim.set('/EVaultSim/n-enqueuers', 1)             # total threads
sim.set('/EVaultSim/server/max-documents', 1)    # docs per col
sim.set('/EVaultSim/batch-size', 1)              # docs per enqueue
sim.set('/EVaultSim/content-size', 1)            # words per doc
sim.set('/EVaultSim/vse-config/vse-index/vse-index-option[@name="cache-mb"]', 1) # MB Cache

sim.set('/EVaultSim/generate-deletes-percent', 25.0)
step << sim.run

# Run the same combination over and over.
# (Lower level calls into "sim" to avoid generating a config file every time.)
sim.set('/EVaultSim/server/initialize-type', 'preserve')
step << sim.do_setup
step << (0..9999).all? {|i| sim.just_run}
sim.do_cleanup

sim.set('/EVaultSim/run-dict-validation', true)
sim.set('/EVaultSim/persist-validation-to-disk', false)
sim.set('/EVaultSim/generate-deletes-percent', 0)
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
