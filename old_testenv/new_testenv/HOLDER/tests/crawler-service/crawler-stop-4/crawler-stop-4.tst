#!/usr/bin/env ruby

require 'misc'
require 'collection'
require 'velocity/collection/restore'

results = TestResults.new('Kill the crawler during a refresh.',
                          'This is simple variant of crawler-stop-2.',
                          'This uses a crawler "stop" API call with kill=true,',
                          'instead of an admin "force stop".')

collection = Collection.restore_saved_collection('crawler-stop-4',
             '/testenv/saved-collections/crawler-service/crawler-stop-4')

def sleep_to_next_whole_minute
  sleep 60-Time.now.to_i%60
end

def wait_for_idle(collection)
  sleep_to_next_whole_minute
  give_up_time = Time.now + 600   # Give up ten minutes from now.
  until collection.indexer_idle? or Time.now > give_up_time
    status = collection.status.xpath('/vse-status/vse-index-status').first
    msg(status.attributes.keys.sort.map {|name|
          '%s="%s"' % [name, status[name]]}.join("\n\t "))
    sleep_to_next_whole_minute
  end

  [collection.indexer_idle?,
   "Indexer idle.",
   "Indexer is not idle. Is it hung?"]
end

results.associate(collection)

msg 'Starting a "refresh-inplace" crawl.'
collection.crawler_start('live', :type => 'refresh-inplace')
sleep 60
(1..10).each do |j|
  sleep_to_next_whole_minute
  msg 'Killing the crawler, pass %d...' % j
  collection.crawler_kill
  sleep 10
  msg 'Resuming the crawler, pass %d...' % j
  collection.crawler_start('live', :type => 'resume')
end

sleep_to_next_whole_minute
msg 'Finally, stopping crawler...'
collection.crawler_stop
msg 'Crawler is now stopped.'

results.add(*wait_for_idle(collection))

results.cleanup_and_exit!
