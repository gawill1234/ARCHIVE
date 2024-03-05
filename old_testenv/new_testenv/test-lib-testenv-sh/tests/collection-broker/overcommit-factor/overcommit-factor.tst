#!/usr/bin/env ruby

# Check the effectiveness of the "overcommit-factor" setting.
# 1) Set "indexer-minimum" to five times the default, leaving
# "overcommit-factor" unset.
# 2) Run many, small, collection searches to determine maximum online
# collections.
# 3) Set "overcommit-factor" to 0.375 (half default) and rerun
# searches to see fewer online collections.
# 4) Set "overcommit-factor" to 1.5 (twice default) and rerun searches
# to see more online collections.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'max-online'
require 'misc'
require 'collection'

step = []
bc = Broker_Config.new

default_indexer_minimum = 367001600
factor = 16                     # Start at sixteen times the default

# We need headroom, so we can prove upward tuning works.
# So, we tune indexer-minimum way up--trying to avoid overloading the target.
# The problem is, if we go too high, we can't see anything.
# Back off until we get multiple collections running.
enqueue_max = 0
while enqueue_max <= 1 do
  factor /= 2.0
  indexer_minimum = ((1+factor)*default_indexer_minimum).to_i
  raise "Can't run more than one small collection!" if factor < 0.1
  bc.set('indexer-minimum' => indexer_minimum)
  msg bc

  enqueue_max = determine_maximum_online_via_enqueue('overcommit-e-baseline-')
  msg "Baseline enqueue maximum online is #{enqueue_max}"
end

search_max = determine_maximum_online_via_search('overcommit-s-baseline-')
msg "Baseline search maximum online is #{search_max}"

bc.set('indexer-minimum' => indexer_minimum, 'overcommit-factor' => 0.375)
msg bc

enqueue_half = determine_maximum_online_via_enqueue('overcommit-e-half-')
step << (enqueue_half<enqueue_max)
msg "Half overcommit-factor allowed #{enqueue_half} online for enqueue"

search_half = determine_maximum_online_via_search('overcommit-s-half-')
step << (search_half<search_max)
msg "Half overcommit-factor allowed #{search_half} online for search"

bc.set('indexer-minimum' => indexer_minimum, 'overcommit-factor' => 1.5)
msg bc

enqueue_double = determine_maximum_online_via_enqueue('overcommit-e-double-')
step << (enqueue_double>enqueue_max)
msg "Double overcommit-factor allowed #{enqueue_double} online for enqueue"

search_double = determine_maximum_online_via_search('overcommit-s-double-')
step << (search_double>search_max)
msg "Double overcommit-factor allowed #{search_double} online for search"

bc.set

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
