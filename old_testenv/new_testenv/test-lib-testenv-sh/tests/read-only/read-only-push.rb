#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'collection'
require 'misc'
require 'read-only-files'
require 'thread'
require 'time'
require 'pmap'

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
    rescue
      body = nil
    end
    @queue << body
  end
end

def timed_ro(collection, mode=nil)
  t1 = Time.now
  if mode
    ro = collection.read_only(mode)
  else
    ro = collection.read_only
  end
  t2 = Time.now
  msg "read-only request took #{t2-t1} seconds, response was:"
  msg "#{ro.inspect}"
  ro
end

def report_enqueue(enqueue_returns, online=true, terse=false)
  # n-success="1" n-failed="0" n-offline="0"
  offline = '1'
  offline = '0' if online
  success = enqueue_returns.select {|r| r =~ / n-success="1".* n-offline="#{offline}" /}
  good_except = enqueue_returns.select {|r| r =~ / error="read-only"/ or
    r =~ /<exception name="search-collection-enqueue-read-only" / or
    r =~ /<exception .* id="SEARCH_ENGINE_READ_ONLY/ or
    r =~ /<error .* id="COLLECTION_SERVICE_READ_ONLY_MODE"/ or
    r =~ /<error .* id="SEARCH_ENGINE_READ_ONLY"/}
  bad_except = (enqueue_returns - success - good_except).select {|r| r  =~ /<exception /}
  other = enqueue_returns - success - good_except - bad_except
  if terse
    msg "#{enqueue_returns.length} enqueue returns so far: #{success.length} success, #{good_except.length} expected exceptions, #{bad_except.length} unexpected exceptions, #{other.length} other."
  else
    msg "#{success.length} successful enqueues (should be greater than zero)."
    msg "#{good_except.length} expected exceptions returned by enqueues (should be greater than zero)."
    msg "#{bad_except.length} unexpected exceptions returns (should be zero)."
    msg "#{other.length} other returns (should be zero)."
    others = other.uniq
    others.each {|o| msg "Saw #{other.select {|e| e==o}.length} of: #{o.inspect}"}
    if others.index(nil)
      msg "'nil' returns indicate Ruby threading issues (in the test script)."
    end
    if others.any? {|o| o =~ /_CONTAINER_/}
      msg "_CONTAINER_ returns usually mean the collection broker crashed."
    end
    msg 'Empty "" returns usually mean timeouts.' if others.index("")
  end
  if bad_except.length > 0
    msg "Example unexpected exception seen:"
    msg bad_except[(bad_except.length*rand).to_i]
  end
  if other.length > 0
    msg "Example other: #{other[(other.length*rand).to_i].inspect}"
  end
  other_tolerance = [success.length, good_except.length].min
  (success.length > 0 and
   good_except.length > 0 and
   bad_except.length < other_tolerance and
   other.length < other_tolerance)
end

def read_only_push(collection_name, online, count=800)
  results = TestResults.new
  # Don't print warnings (we expect many).
  results.print_severity = results.fail_severity

  # This is a hack... Should be generalized to somewhere else...
  emfb = Collection.new('example-metadata').filebase
  my_path = emfb[0..emfb.index('data')+4] + 'testing/'
  collection = Collection.new(collection_name)
  results.associate(collection)
  collection.delete
  collection.create('default-broker-push',
                    '<vse-meta>' +
                    '<vse-meta-info name="live-crawl-dir">' +
                    my_path + collection.name + '/live</vse-meta-info>' +
                    '<vse-meta-info name="staging-crawl-dir">' +
                    my_path + collection.name + '/staging</vse-meta-info>' +
                    '</vse-meta>')

  queue = Queue.new
  stage = (0...count).map {|i| FastEnqueue.new(collection.name, i, queue)}
  Thread.new {
    msg "Starting #{count} collection-broker-enqueue-xml calls to #{collection.name}"
    stage.peach {|e| e.invoke}
  }

  # Wait for the first enqueue request to return
  enqueue_returns = [queue.pop]
  msg "Saw first enqueue response..."

  msg "Asking for read-only mode=enable"
  ro1 = timed_ro(collection, :enable)
  while ro1['acquired'].nil?
    sleep 1
    ro1 = timed_ro(collection)
  end

  no_progress_count = 0
  while enqueue_returns.length < count and no_progress_count < 30 do
    sleep 60 - (Time.new.to_f % 60)
    prev_length = enqueue_returns.length
    begin
      while true do
        enqueue_returns << queue.pop(true)
      end
    rescue ThreadError
    end
    if enqueue_returns.length == prev_length
      msg 'No enqueue progress ...'
      no_progress_count += 1
    else
      report_enqueue(enqueue_returns, online, true)
      no_progress_count = 0
    end
  end

  results.add(no_progress_count == 0,
              "Enqueues complete",
              "Too much time since any enqueue progress.")
  results.add(report_enqueue(enqueue_returns, online),
              "Need some success, some expected exceptions and few others.")

  ro2 = timed_ro(collection)
  results.add(ro1 == ro2,
              "read-only status matches",
              "read-only status changed")

  results.add(*fail_files_newer(collection))
  results
end
