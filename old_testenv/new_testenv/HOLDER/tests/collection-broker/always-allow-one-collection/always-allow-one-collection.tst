#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'pmap'
require 'config'
require 'misc'
require 'collection'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com">
    <crawl-data content-type="text/plain"
                encoding="text">
      Nothing to see here. Move along.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

def one_combo(results, expect, config)
  name_base = 'always-allow-one-collection-'
  collection = (0..1).map {|i| Collection.new("#{name_base}#{i}")}
  collection.each {|c| c.delete; c.create}
  bc = Broker_Config.new
  bc.set(config)
  msg "Now: #{bc}"

  messages = collection.pmap do |c|
    resp = c.vapi.collection_broker_enqueue_xml(:collection => c.name,
                                                :crawl_nodes => CRAWL_NODES)
    if resp.xpath('//msg').empty?
      "Response from cb-enqueue to '#{c.name}':\n\t" + resp.to_s
    else
      "Messages returned by cb-enqueue to '#{c.name}':\n\t" +
        (resp.xpath('//msg').map {|t| t.content.to_s}).join("\n\t")
    end
  end

  messages.each {|m| msg m}

  online = collection.map {|c| c.crawler_service_status}
  results.add(((online.count {|x| x == 'running'}) == expect),
              "crawler/service-status #{online.inspect}")

  online = collection.map {|c| c.indexer_service_status}
  results.add(((online.count {|x| x == 'running'}) == expect),
              "indexer/service-status #{online.inspect}")
end

results = TestResults.new('Test the effectiveness of the' +
                          '"always-allow-one-collection" setting.',
                          '0) Baseline: default settings,',
                          '   ingest to two collections and check that both',
                          '   collections come online.',
                          '1) Set "maximum-collections" to "0",',
                          '   leaving "always-allow-one-collection" unset,',
                          '   check that one collection will come online.',
                          '2) Set "always-allow-one-collection" to "true",',
                          '   check that one collection will come online.',
                          '3) Set "always-allow-one-collection" to "false",',
                          '   check that no collections will come online.')

one_combo(results, 2, {})
one_combo(results, 1, {'maximum-collections' => '0'})
one_combo(results, 1, {'always-allow-one-collection' => 'true',
                       'maximum-collections' => '0'})
one_combo(results, 0, {'always-allow-one-collection' => 'false',
                       'maximum-collections' => '0'})

# Restore the collection broker to it's default settings.
Broker_Config.new.set

results.cleanup_and_exit!
