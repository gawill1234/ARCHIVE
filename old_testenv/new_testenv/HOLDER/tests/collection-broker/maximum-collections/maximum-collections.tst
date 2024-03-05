#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'max-online'
require 'misc'
require 'collection'

def near_enough(a, b)
  (a-b).abs <= (a+b)/10.0
end

results = TestResults.new('Test the "maximum-collections" setting.',
                          '0) experimentally determine the number of',
                          '   small collections that will be brought',
                          '   on-line for enqueue and search.',
                          '1) Rerun the experiment with maximum-collections',
                          '   set to half of what was seen in step 0.',
                          '2) Rerun the experiment with maximum-collections',
                          '   set to double what was seen in step 0.')

# Only print errors we'll fail for. (We expect many warnings.)
results.print_severity = results.fail_severity

bc = Broker_Config.new
bc.set
msg bc

enqueue_max = determine_maximum_online_via_enqueue('max-enqueue-baseline-')
msg "Baseline enqueue maximum online is #{enqueue_max}"
search_max = determine_maximum_online_via_search('max-search-baseline-')
msg "Baseline search maximum online is #{search_max}"

half = ([search_max, enqueue_max].min/2).to_i
double = ([search_max, enqueue_max].max*2).to_i

sleep 60
bc.set('maximum-collections' => half)
msg bc
sleep 60

enqueue_half = determine_maximum_online_via_enqueue('max-enqueue-half-')
results.add((enqueue_half<=half and enqueue_half>=half-2),
            "enqueue maximum online limited to #{half} was #{enqueue_half}")

search_half = determine_maximum_online_via_search('max-search-half-')
results.add((search_half<=half and search_half>=half-2),
            "search maximum online limited to #{half} was #{search_half}")

bc.set('maximum-collections' => double)
msg bc

enqueue_double = determine_maximum_online_via_enqueue('max-enqueue-double-')
results.add(near_enough(enqueue_double, enqueue_max),
            "enqueue maximum online limited to #{double} was #{enqueue_double}")

search_double = determine_maximum_online_via_search('max-search-double-')
results.add(near_enough(search_double, search_max),
            "search maximum online limited to #{double} was #{search_double}")

results.cleanup_and_exit!
