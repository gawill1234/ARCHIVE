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

t1 = Thread.new {
  system '$TEST_ROOT/lib/multi_search.py -p2 "-ccb-tunable-00 cb-tunable-01"'
}

sleep 120             # Wait for searching to get into a steady state.

collection = Collection.new('cb-search-priority-1-0')
collection.delete               # We want to be sure to start fresh

t2 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c1 -z20000 -Ncb-search-priority-1-'
}

s1 = t1.value                   # Wait for searches

n_docs = collection.index_n_docs
s3 = (n_docs == 0)
msg "#{collection.name} n_docs = #{n_docs}"

s2 = t2.value                   # Wait for enqueues and offline queue processing
collection.stop

if s1 and s2 and s3
  msg 'Test passed.'
  exit 0
end

msg "Test failed #{s1} #{s2} #{s3}"
exit 1
