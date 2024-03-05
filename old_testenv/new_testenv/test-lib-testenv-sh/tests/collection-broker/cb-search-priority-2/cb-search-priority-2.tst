#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'
require 'collection'

# FIXME The loading collection should have a huge memory footprint,
# instead of using the maximum-collections

system '$TEST_ROOT/tests/collection-broker/tunable.py -c2 -Ncb-tunable-0'

bc = Broker_Config.new
msg bc.set('maximum-collections' => '1')

collection = Collection.new('cb-search-priority-2-0')
collection.delete               # We want to be sure to start fresh


t1 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c1 -z20000 -Ncb-search-priority-2-'
}

sleep 120             # Wait for the load to run for a while.

online_n_docs = collection.index_n_docs
msg "Starting searches after #{online_n_docs} indexed into #{collection.name}"
raise 'No online enqueueing happened?' unless online_n_docs > 0

s2 = system '$TEST_ROOT/lib/multi_search.py -p2 "-ccb-tunable-00 cb-tunable-01"'

post_search_n_docs = collection.index_n_docs
msg "Searches complete with #{post_search_n_docs} in #{collection.name}"
# FIXME Is one hundred an appropriate threshold?
s3 = post_search_n_docs < online_n_docs+100
if not s3
  msg 'Failing: Too many documents indexed during searches'
end

s1 = t1.value                   # Wait for load to complete

if s1 and s2 and s3
  msg 'Test passed.'
  exit 0
end

msg "Test failed #{s1} #{s2} #{s3}"
exit 1
