#!/usr/bin/env ruby

# Check the effectiveness of the "indexer-overhead" setting.
# 1) Set "overcommit-factor" to "0.1" (very low), leaving
# "indexer-overhead" unset.
# 2) Run many, small, collection ingestion to determine maximum online
# collections.
# 3) Set "indexer-overhead" to "131072000" (half the default), rerun
# ingestion to see more online collections.
# 4) Set "indexer-overhead" to "524288000" (twice the default), rerun
# ingestion to see fewer online collections.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'max-online'
require 'misc'
require 'collection'

step = []
bc = Broker_Config.new

DEFAULT_OVERCOMMIT_FACTOR = 0.75
DEFAULT_INDEXER_OVERHEAD = 262144000

# We need headroom, so we can prove upward tuning works.  So, we tune
# overcommit-factor way down--trying to avoid overloading the target.
# The problem is, if we go too low, we can't see anything. Back off
# until we can see multiple collections running.
overcommit_factor = 0.0
enqueue_max = 0
while enqueue_max <= 1 do
  overcommit_factor += 0.1
  raise "Can't run more than one small collection!" \
        if overcommit_factor >= DEFAULT_OVERCOMMIT_FACTOR
  bc.set('overcommit-factor' => overcommit_factor)
  msg bc
  enqueue_max = determine_maximum_online_via_enqueue('indexer-overhead-e-baseline-')
  msg "Baseline enqueue maximum online is #{enqueue_max}"
end

search_max = determine_maximum_online_via_search('indexer-overhead-s-baseline-')
msg "Baseline search maximum online is #{search_max}"

bc.set('overcommit-factor' => overcommit_factor,
       'indexer-overhead' => DEFAULT_INDEXER_OVERHEAD*0)
msg bc

enqueue_lower = determine_maximum_online_via_enqueue('indexer-overhead-e-lower-')
step << (enqueue_lower>enqueue_max)
msg "Lower indexer-overhead allowed #{enqueue_lower} online for enqueue"

search_lower = determine_maximum_online_via_search('indexer-overhead-s-lower-')
step << (search_lower>search_max)
msg "Lower indexer-overhead allowed #{search_lower} online for search"

bc.set('overcommit-factor' => overcommit_factor,
       'indexer-overhead' => DEFAULT_INDEXER_OVERHEAD*1.2)
msg bc

enqueue_higher = determine_maximum_online_via_enqueue('indexer-overhead-e-higher-')
step << (enqueue_higher<enqueue_max)
msg "Higher indexer-overhead allowed #{enqueue_higher} online for enqueue"

search_higher = determine_maximum_online_via_search('indexer-overhead-s-higher-')
step << (search_higher<search_max)
msg "Higher indexer-overhead allowed #{search_higher} online for search"

bc.set

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
