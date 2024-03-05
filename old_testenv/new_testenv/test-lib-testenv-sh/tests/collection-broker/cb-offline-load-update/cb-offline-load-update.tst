#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'
require 'evault-sim'

start_iso8601 = iso8601

collection = Collection.new('vivisimo0')

bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

step = []

sim = EVaultSim.new
sim.set('/EVaultSim/server/n-users', 1)
sim.set('/EVaultSim/generate-data-for-deletes', true)
sim.set('/EVaultSim/generate-deletes-for-deletes', true)
step << sim.run

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be!'
end

sim.set('/EVaultSim/server/initialize-type', 'preserve')
sim.set('/EVaultSim/generate-data-for-deletes', false)
step << sim.run

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be!'
end

sim.set('/EVaultSim/generate-data-for-deletes', true)
step << sim.run

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be!'
end

sim.set('/EVaultSim/generate-data-for-deletes', false)
step << sim.run

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be!'
end

msg 'Reset the collection broker settings to the defaults.'
bc.set

# Give validation a chance: wait for the collection broker to start the crawler
until collection.crawler_service_status == 'running'
  sleep 1
end

msg 'Saw the crawler running'

sim.set('/EVaultSim/validation-only', true)
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
