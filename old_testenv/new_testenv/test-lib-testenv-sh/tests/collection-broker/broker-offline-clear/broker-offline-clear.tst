#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'testenv'
require 'config'
require 'misc'
require 'collection'
require 'pmap'

results = TestResults.new

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

collections = (0...9).map {|i| Collection.new("cb-seq-agg-#{i}")}

msg 'Deleting existing collections (if any).'
collections.peach {|c| c.delete}

msg 'Setting maximum-collections=1 ...'
bc = Broker_Config.new
bc.set('maximum-collections' => '1')
msg bc

msg 'Running small-sequential-aggressive-search ...'
results.add(system('$TEST_ROOT/tests/collection-broker/small-sequential-aggressive-search.py 9'),
            "enqueues and searches complete.",
            "enqueues and searches failed?")

# Make sure the collections are not running.
collections.peach {|c| c.stop}

msg 'Checking collection broker status'
cbs = vapi.collection_broker_status

9.times do |i|
  name = "cb-seq-agg-#{i}"
  has_offline_queue = cbs.xpath("/collection-broker-status-response/collection[@name='#{name}']").first['has-offline-queue'].to_s
  results.add(has_offline_queue.to_s == 'false',
              "#{name}  has-offline-queue='#{has_offline_queue}'")
end

results.cleanup_and_exit!
