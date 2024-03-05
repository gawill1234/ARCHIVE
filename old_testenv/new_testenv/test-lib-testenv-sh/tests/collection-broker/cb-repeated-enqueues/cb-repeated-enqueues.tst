#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'

collection = Collection.new('cb-tunable-0')
collection.delete

start_iso8601 = iso8601

s1 = system '$TEST_ROOT/tests/collection-broker/tunable.py -c1'

# Make sure it's not running (before we try to offline enqueue to it).
collection.stop

bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

# This thread is likely to finish, with a success status, too early.
t2 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c1'
}

sleep 60

msg 'Revert the collection broker settings to the defaults.'
bc.set

s2 = t2.value

# Wait for the crawler to stop
until collection.crawler_service_status != 'running'
  sleep 1
end

# Then wait for the indexer to stop
until collection.indexer_service_status != 'running'
  sleep 1
end

# With the crawl/index complete, we can check the final count
n_docs = collection.index_n_docs
msg "Final n-docs is #{n_docs}"
s3 = (n_docs == 2000)

end_iso8601 = iso8601

msg "System Report from #{start_iso8601} to #{end_iso8601}"
s4 = system "$TEST_ROOT/lib/system_report.py #{start_iso8601} #{end_iso8601}"
msg "End of System Report"

if s1 and s2 and s3 and s4
  msg 'Test passed'
  exit 0
end

msg "Test failed #{s1} #{s2} #{s3} #{s4}"
exit 1
