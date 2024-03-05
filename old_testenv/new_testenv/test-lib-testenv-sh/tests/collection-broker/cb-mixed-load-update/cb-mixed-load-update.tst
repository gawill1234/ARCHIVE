#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'
require 'evault-sim'

results = TestResults.new("Online and offline cb-enqueues, including updates,",
                          "using EVaultSim.")

collection = Collection.new('vivisimo0')

bc = Broker_Config.new
bc.set

sim = EVaultSim.new
sim.set('/EVaultSim/server/n-users', 1)
sim.set('/EVaultSim/generate-data-for-deletes', true)
sim.set('/EVaultSim/generate-deletes-for-deletes', true)
results.add(sim.run, "EVaultSIM first on-line run")

sim.set('/EVaultSim/server/initialize-type', 'preserve')
sim.set('/EVaultSim/generate-data-for-deletes', false)
results.add(sim.run, "EVaultSIM second on-line run")

cbs = collection.broker_status
results.add(cbs[:is_online] == 'true',
            "Collection broker says is-online=#{cbs[:is_online]}" +
            " for #{collection.name}")

bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

collection.stop
cbs = collection.broker_status
msg "Collection broker says is-online=#{cbs[:is_online]}" +
  " for #{collection.name}."
while cbs.empty? or cbs[:is_online] == 'true'
  msg "Waiting for offline..."
  sleep 10
  cbs = collection.broker_status
end
results.add(cbs[:is_online] == 'false',
            "Collection broker says is-online=#{cbs[:is_online]}" +
            " for #{collection.name}")

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be! (sanity check)'
end

sim.set('/EVaultSim/generate-data-for-deletes', true)
results.add(sim.run, "EVaultSIM first offline run")

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be! (first offline pass)'
end

sim.set('/EVaultSim/generate-data-for-deletes', false)
results.add(sim.run, "EVaultSIM second offline run")

if collection.crawler_service_status == 'running'
  raise 'Crawler running when it should not be! (second offline pass)'
end

msg 'Reset the collection broker settings to the defaults.'
bc.set

# Give validation a chance: wait for the collection broker to start the crawler
until collection.crawler_service_status == 'running'
  msg "Waiting for the collection broker to start the crawler."
  sleep 10
end

msg 'Saw the crawler running'

sim.set('/EVaultSim/validation-only', true)
results.add(sim.run, "EVaultSIM validation pass")

results.cleanup_and_exit!
