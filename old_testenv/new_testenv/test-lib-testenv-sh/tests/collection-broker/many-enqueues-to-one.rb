#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'thread'
require 'misc'
require 'collection'
require 'config'

class FastEnqueue
  attr_reader :prepared, :queue, :vapi

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

  def initialize(name, index, queue)
    @queue = queue
    @vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
    @prepared = @vapi.prepare(:collection_broker_enqueue_xml,
                              {:collection => name,
                                :crawl_nodes => CRAWL_NODES % ([index]*2)})
  end

  def invoke
    begin
      body = @vapi.invoke(@prepared).body
    rescue => ex
      body = ex.to_s
    end
    @queue << body
  end
end

def report(c)
  cbs = c.vapi.collection_broker_status
  scs = c.status

  msg 'Search collection status says:'
  crawler_status = scs.xpath('//crawler-status').first
  msg "\tcrawler-status/@service-status = #{crawler_status['service-status']}"
  msg "\tcrawler-status/@n-offline-queue = #{crawler_status['n-offline-queue']}"
  indexer_status = scs.xpath('//vse-index-status').first
  msg "\tvse-index-status/@service-status = #{indexer_status['service-status']}"
  msg "\tvse-index-status/@idle = #{indexer_status['idle']}"
  msg "\tvse-index-status/@n-docs = #{indexer_status['n-docs']}"

  cbs_collection = cbs.xpath("//collection[@name='#{c.name}']")
  if cbs_collection.empty?
    msg "FAIL: The Collection Broker status does not mention #{c.name}"
  else
    msg 'The Collection Broker status says:'
    cbs_collection.first.attributes.each {|n,v| msg "\t#{n}='#{v}'"}
    indexer_status['n-docs'].to_s.to_i
  end
end

def many_enqueues_to_one(collection, count)
  queue = Queue.new
  stage = (0..count-1).map {|i| FastEnqueue.new(collection.name, i, queue)}
  msg "Sending #{stage.length} enqueues to #{collection.name} in parallel"
  threads = stage.map {|x| Thread.new(x) {|e| e.invoke}}

  responses = []
  no_progress_count = 0
  while responses.length < count and no_progress_count < 120 do
    sleep 10.0/(responses.length/100+1)
    prev_length = responses.length
    begin
      while true do
        responses << queue.pop(true)
      end
    rescue
    end
    if responses.length == prev_length
      msg 'No enqueue progress ...'
      no_progress_count += 1
    else
      successes = responses.count {|r| r =~ / n-success="1" /}
      msg "#{responses.length} enqueues, #{successes} successes and #{responses.length-successes} failures"
      no_progress_count = 0
    end
  end
  responses
end

if __FILE__ == $0
  count = 1000

  results = TestResults.new('Issue many collection-broker-enqueue-xml',
                            'calls very quickly ("many" is %d).' % count)

  collection = Collection.new('cb-many-enqueues-to-one')
  collection.delete

  bc = Broker_Config.new
  bc.set
  bc.collection_broker_down

  collection.create('default-broker-push')
  responses = many_enqueues_to_one(collection, count)
  failures  = responses.reject {|r| r =~ / n-success="1" /}
  success_count = responses.count {|r| r =~ / n-success="1" /}
  results.add(failures.length < 0.3*count,
              "Enqueuing complete with #{failures.length} failures.",
              "Too many enqueue failures #{failures.length}.")
  failures.uniq.each {|f| msg "#{failures.count {|x| x==f}} of: #{f.inspect}"}
  results.add_number_equals(success_count, report(collection), "n-docs")
  results.cleanup_and_exit!
end
