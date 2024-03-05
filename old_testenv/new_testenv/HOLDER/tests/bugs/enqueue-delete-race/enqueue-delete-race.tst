#!/usr/bin/env ruby

require 'pmap'
require 'misc'
require 'collection'
require 'gronk'

CRAWL_URLS = '<crawl-urls synchronization="indexed-no-sync" >
  <crawl-url status="complete" url="http://%s">
    <crawl-data content-type="text/plain">My word is "%s".</crawl-data>
  </crawl-url>
</crawl-urls>'

results = TestResults.new('Test a race condition between enqueues',
                          'and collection-delete (bug 26786).',
                          '    Pound away with tiny enqueues,',
                          'while deleting and recreating the collection.',
                          'Fail if multiple crawlers or indexers are running,',
                          'or for "errors-high" messages in system reporting.')

gronk = Gronk.new

crawlers = gronk.get_pid_list(:crawler)
raise 'Crawlers running at test start %s' % crawlers.inspect unless
  crawlers.length==0
indexers = gronk.get_pid_list(:indexer)
raise 'Indexers running at test start %s' % indexers.inspect unless
  indexers.length==0

collection = Collection.new(TESTENV.test_name)
collection.delete
collection.create

WORDS = open("#{ENV['TEST_ROOT']}/files/top_5k_words") {|f|
  f.readlines
}.map{|w| w.strip}


enqueuers = Thread.new() {
  enq_resps = WORDS.pmap{|w|
    begin
      Collection.new(collection.name).enqueue_xml(CRAWL_URLS % [w,w])
    rescue
      w
    end
  }
  msg 'Enqueuing complete.'
  msg 'Saw %d successful enqueues' %  enq_resps.count{|r| r == true}
  msg 'Saw %d failed enqueues' %  enq_resps.count{|r| r == false}
  msg 'Saw %d enqueue exceptions' %  enq_resps.count{|r|
    r != true and r != false}
}

msg 'delete'
collection.delete
while enqueuers.status
  crawlers = gronk.get_pid_list(:crawler)
  results.add(crawlers.length==0, 'No crawlers running',
              'Too many crawlers %s' % crawlers.inspect)
  indexers = gronk.get_pid_list(:indexer)
  results.add(indexers.length==0, 'No indexers running',
              'Too many indexers %s' % indexers.inspect)
  # Stop the test when things get really bad.
  break if crawlers.length > 2 or indexers.length > 2
  msg 'create'
  collection.create
  sleep 0.1
  msg 'delete'
  collection.delete
end

results.cleanup_and_exit!
