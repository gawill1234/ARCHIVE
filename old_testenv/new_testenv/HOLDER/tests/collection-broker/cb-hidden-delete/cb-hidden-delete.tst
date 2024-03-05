#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'

CRAWL_NODES = '<crawl-urls><crawl-url enqueue-type="reenqueued" status="complete" synchronization="indexed-no-sync" url="http://vivisimo.com"><crawl-data content-type="text/plain" encoding="text">Nothing to see here. Move along.</crawl-data></crawl-url></crawl-urls>'

message_xpath = '/collection-broker-enqueue-response/log/msg/message'

def cb_online(vapi)
  online_xpath = '/collection-broker-status-response' +
    '/collection[@is-ignored="false"]/@name'
  cbs = vapi.collection_broker_status
  online = cbs.xpath(online_xpath)
  if online.length == 0
    msg 'CB reports no collections online.'
  else
    msg 'CB online collections: %s' % online.map{|a| a.to_s}.join(', ')
  end
end

results = TestResults.new("Test for bug 21625",
                          "    1. set max collections to 1",
                          "    2. start broker",
                          "    3. start collection A",
                          "    4. stop broker",
                          "    5. delete collection A",
                          "    6. start broker",
                          "    7. try to start collection B")

bc = Broker_Config.new
bc.set('maximum-collections' => 1)
msg bc
cb_online(bc.vapi)

a = Collection.new(TESTENV.test_name + '-a')
b = Collection.new(TESTENV.test_name + '-b')
results.associate(a)
results.associate(b)

a.create
msg "Created #{a.name}, enqueuing one doc"
enqueue = a.vapi.collection_broker_enqueue_xml(:collection => a.name,
                                               :crawl_nodes => CRAWL_NODES)
enqueue.xpath(message_xpath).each {|m| puts m.content}
found = a.broker_search
results.add_equals(1, found, 'total search results in %s' % a.name)
msg "Sleeping in the hope that collection broker state will be persisted."
sleep 20
msg "Stopping the collection broker."
bc.collection_broker_down
msg bc.vapi.collection_broker_status
msg "Deleting collection #{a.name}."
a.delete
sleep 1
msg "Starting the collection broker."
bc.vapi.collection_broker_start
cb_online(bc.vapi)
sleep 20
cb_online(bc.vapi)
b.create
msg "Created #{b.name}, enqueuing one doc"
enqueue = b.vapi.collection_broker_enqueue_xml(:collection => b.name,
                                               :crawl_nodes => CRAWL_NODES)
enqueue.xpath(message_xpath).each {|m| puts m.content}
found = b.broker_search
results.add_equals(1, found, 'total search results in %s' % b.name)

results.cleanup_and_exit!
