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
msg bc.set('maximum-collections' => '1', 'prefer-requests' => 'enqueue')

c0 = Collection.new('cb-enqueue-priority-2-0')
c1 = Collection.new('cb-enqueue-priority-2-1')
c0.delete                       # We want to be sure to start fresh
c1.delete                       # We want to be sure to start fresh

t1 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c2 -z10000 -Ncb-enqueue-priority-2-'
}

sleep 120             # Wait for the load to run for a while.

s2 = system '$TEST_ROOT/lib/multi_search.py -p2 "-ccb-tunable-00 cb-tunable-01"'

# FIXME need to check search performance

s1 = t1.value                   # Wait for load to complete
c0.stop
c1.stop

if s1 and s2
  msg 'Test passed.'
  exit 0
end

msg "Test failed #{s1} #{s2}"
exit 1
