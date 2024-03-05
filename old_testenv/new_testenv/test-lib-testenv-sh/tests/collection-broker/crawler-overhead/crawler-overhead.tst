#!/usr/bin/env ruby

# Check the effectiveness of the "crawler-overhead" setting.
# 1) Set "overcommit-factor" to "0.1" (very low), leaving
# "crawler-overhead" unset.
# 2) Run many, small, collection ingestion to determine maximum online
# collections.
# 3) Set "crawler-overhead" to "131072000" (half the default), rerun
# ingestion to see more online collections.
# 4) Set "crawler-overhead" to "524288000" (twice the default), rerun
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
DEFAULT_CRAWLER_OVERHEAD = 262144000

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
  enqueue_max = determine_maximum_online_via_enqueue('crawler-min-e-baseline-')
  msg "Baseline enqueue maximum online is #{enqueue_max}"
end

search_max = determine_maximum_online_via_search('crawler-min-s-baseline-')
msg "Baseline search maximum online is #{search_max}"

bc.set('overcommit-factor' => overcommit_factor,
       'crawler-overhead' => DEFAULT_CRAWLER_OVERHEAD/2)
msg bc

enqueue_half = determine_maximum_online_via_enqueue('crawler-min-e-half-')
step << (enqueue_half>enqueue_max)
msg "Half crawler-overhead allowed #{enqueue_half} online for enqueue"

search_half = determine_maximum_online_via_search('crawler-min-s-half-')
step << (search_half>=search_max)
msg "Half crawler-overhead allowed #{search_half} online for search"

bc.set('overcommit-factor' => overcommit_factor,
       'crawler-overhead' => DEFAULT_CRAWLER_OVERHEAD*2)
msg bc

enqueue_double = determine_maximum_online_via_enqueue('crawler-min-e-double-')
step << (enqueue_double<enqueue_max)
msg "Double crawler-overhead allowed #{enqueue_double} online for enqueue"

search_double = determine_maximum_online_via_search('crawler-min-s-double-')
step << (search_double<=search_max)
msg "Double crawler-overhead allowed #{search_double} online for search"

bc.set

if step.all?
  msg 'Test passed'
  exit 0
end

msg "Test failed. Steps: #{step.map {|s| s ? 'pass' : 'fail' }.join(', ')}"
exit 1
