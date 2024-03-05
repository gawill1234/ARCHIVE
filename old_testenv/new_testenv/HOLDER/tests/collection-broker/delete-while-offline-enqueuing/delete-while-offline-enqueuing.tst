#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'collection'
require 'config'
require 'misc'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/item%i">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here in item %i.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

step = []

bc = Broker_Config.new
bc.set('always-allow-one-collection' => false, 'maximum-collections' => 0)

collection = Collection.new(File.basename($0)[/[^.]*/])
collection.delete
collection.create('default-broker-push')

count = 500

prepared = (0..count-1).map do |i|
  collection.vapi.prepare(:collection_broker_enqueue_xml,
                          {:collection => collection.name,
                            :crawl_nodes => CRAWL_NODES % [i, i]})
end

msg 'Starting offline enqueues.'

threads = prepared.map do |p|
  Thread.new(p) do |x|
    Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password).invoke(x).body
  end
end

sleep 1

msg 'Attempting to delete the collection.'
collection.vapi.search_collection_delete(:collection => collection.name)
# The test will blow out with an exception if the delete fails.
step << true
msg 'Delete successful.'

results = threads.map {|t| t.value}

xml = results.map {|r| Nokogiri::XML(r)}
exceptions = xml.select {|x| x.xpath('//exception[@name="search-collection-invalid-name"]')}
errors = xml.select {|x| x.xpath('/exception//error[@id="SEARCH_ENGINE_NO_CONFIG"]')}
step << (exceptions.length > 0 or errors.length > 0)
msg "Saw #{exceptions.length} of the expected exceptions."
msg "Saw #{errors.length} of the expected errors."

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
