#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'collection'
require 'config'
require 'read-only-files'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/dummy">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

results = TestResults.new

bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

collection = Collection.new(File.basename($0)[0..-5])
results.associate(collection)
collection.delete
collection.create
ro_request = collection.read_only(:enable)
msg ro_request.inspect
results.add((not ro_request['acquired'].nil?),
            "'acquired' read-only immediately.",
            "read-only not 'acquired' immediately for new, offline collection.")

sleep 10

begin
  ret = collection.vapi.collection_broker_enqueue_xml(
    :collection => collection.name, :crawl_nodes => CRAWL_NODES)
  results.add(false, "collection_broker_enqueue_xml did not throw an exception.")
  msg ret
rescue => ex
  results.add(true, "collection_broker_enqueue_xml threw an exception")
end

results.cleanup_and_exit!
