#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/item/%s">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here in item %s.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

def pass(step)
  step[-1] ? 'pass' : 'fail'
end

def do_read_only(step, collection, note)
  msg "#{note} collection named '#{collection.name}'"

  # Check status for a new (empty) collection
  status = collection.read_only
  step << (status == {'collection' => collection.name, 'mode'=>'disabled'})
  msg "read-only status for collection #{status.inspect} - #{pass(step)}"

  # Make sure a bad mode value returns an exception.
  begin
    req = collection.read_only(:bad)
    msg "No exception returned for a bad mode value #{req.inspect} - fail."
    step << false
  rescue
    msg "Got an exception for a bad mode value - pass."
    step << true
  end

  # Enable read only for a new (empty) collection
  req = collection.read_only(:enable)
  requested = req['requested']
  step << (req['mode'] == 'pending' or req['mode'] == 'enabled')
  msg "read-only enable returned #{req.inspect} - #{pass(step)}"

  # Immediate check of status should say 'pending' or 'enabled', same requested
  status = collection.read_only
  step << ((status['mode'] == 'pending' or status['mode'] == 'enabled') and 
           status['requested'] == req['requested'])
  msg "read-only status returned #{status.inspect} - #{pass(step)}"

  # Wait for read-only enabled
  while collection.read_only['mode'] == 'pending' do
    # FIXME Should give up it this takes too long...
    sleep 1
  end

  msg "service-status: crawler is '#{collection.crawler_service_status}', indexer is '#{collection.indexer_service_status}'"

  # Another check of status should say 'enabled', same requested
  status = collection.read_only
  step << (status['mode'] == 'enabled' and status['requested'] == req['requested'])
  msg "read-only status again returned #{status.inspect} - #{pass(step)}"

  # Now that we're in read-only enabled, ask for it again.
  # This should be an exception. (A no-op is acceptable as well.)
  begin
    again = collection.read_only(:enable)
    step << (again['mode'] == 'enabled' and 
             again['requested'] == req['requested'])
    msg "read-only enable again says #{again.inspect} - #{pass(step)}"
  rescue
    step << true
    msg "read-only enable again returned an exception - #{pass(step)}"
  end
  
  # Make sure we're cleanly enabled before moving on (should be a no-op)
  collection.read_only_enable
  
  disable = collection.read_only(:disable)
  step <<  (disable == {'collection' => collection.name, 'mode'=>'disabled'})
  msg "read-only disable says #{disable.inspect} - #{pass(step)}"

  # Now that we're out of read-only, ask to disable again.
  # This should be an exception. (A no-op is acceptable as well.)
  begin
    again = collection.read_only(:disable)
    step <<  (again == {'collection' => collection.name, 'mode'=>'disabled'})
    msg "read-only disable again says #{again.inspect} - #{pass(step)}"
  rescue
    step << true
    msg "read-only disable again returned an exception - #{pass(step)}"
  end

  msg "service-status: crawler is '#{collection.crawler_service_status}', indexer is '#{collection.indexer_service_status}'"
end

step = []

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

# Expect exceptions for a non-existent collection
no_collection = Collection.new('non-existent-collection-read-only')
['status', 'enable', 'disable', 'bad'].each do |arg|
  begin
    status = no_collection.read_only(arg)
    step << false
    msg "No exception for read-only(#{arg}) for a non-existent collection - fail"
  rescue
    step << true
    msg "Got an exception for read-only(#{arg}) for a non-existent collection - pass"
  end
end

collection = Collection.new(File.basename($0)[/[^.]*/])
collection.delete
collection.create

# brand new collection
do_read_only(step, collection, 'new')

# idle collection, with crawler and indexer running
collection.enqueue_xml(CRAWL_NODES % ['first', 'first'])
# Wait for the enqueued item to appear
while collection.broker_search < 1 do
  sleep 1
end
sleep 1                         # Let the collection go idle
do_read_only(step, collection, 'idle')

# Killed crawler and indexer
collection.enqueue_xml(CRAWL_NODES % ['second', 'second'])
collection.crawler_kill
collection.indexer_kill
do_read_only(step, collection, 'killed')

# Active crawl
example_metadata = Collection.new('example-metadata')
example_metadata.clean
Thread.new { Collection.new('example-metadata').crawler_start }
do_read_only(step, example_metadata, 'crawling')

# Clearing offline queue

if step.all?  
  msg 'Test passed'
  collection.delete
  exit 0
end

passed = step.select {|s| s}.length
failed = step.reject {|s| s}.length

msg "Test failed. #{passed} steps passed and #{failed} steps failed."
exit 1
