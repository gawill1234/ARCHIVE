#!/usr/bin/env ruby

# Check the effectiveness of the "minimum-free-memory" setting.
# 1) Set "overcommit-factor" to "0.1" (very low), leaving
# "minimum-free-memory" unset.
# 2) Run many, small, collection searches to determine maximum online
# collections.
# 3) Set "minimum-free-memory" to "1", rerun searches to see more
# online collections.
# 4) Set "minimum-free-memory" to "2621440000" (ten times the
# default), rerun searches to see fewer online collections.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'max-online'
require 'misc'
require 'collection'

step = []
bc = Broker_Config.new

DEFAULT_OVERCOMMIT_FACTOR = 0.75
DEFAULT_MINIMUM_FREE_MEMORY = 262144000

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
  enqueue_max = determine_maximum_online_via_enqueue('min-free-e-baseline-')
  msg "Baseline enqueue maximum online is #{enqueue_max}"
end

search_max = determine_maximum_online_via_search('min-free-s-baseline-')
msg "Baseline search maximum online is #{search_max}"

bc.set('overcommit-factor' => overcommit_factor,
       'minimum-free-memory' => 1)
msg bc

enqueue_one = determine_maximum_online_via_enqueue('min-free-e-one-')
step << (enqueue_one>enqueue_max)
msg "minimum-free-memory = 1 allowed #{enqueue_one} online for enqueue"

search_one = determine_maximum_online_via_search('min-free-s-one-')
step << (search_one>search_max)
msg "minimum-free-memory = 1 allowed #{search_one} online for search"

bc.set('overcommit-factor' => overcommit_factor,
       'minimum-free-memory' => 10*DEFAULT_MINIMUM_FREE_MEMORY)
msg bc

enqueue_ten = determine_maximum_online_via_enqueue('min-free-e-ten-')
step << (enqueue_ten<enqueue_max)
msg "Ten times minimum-free-memory allowed #{enqueue_ten} online for enqueue"

search_ten = determine_maximum_online_via_search('min-free-s-ten-')
step << (search_ten<search_max)
msg "Ten times minimum-free-memory allowed #{search_ten} online for search"

bc.set

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
