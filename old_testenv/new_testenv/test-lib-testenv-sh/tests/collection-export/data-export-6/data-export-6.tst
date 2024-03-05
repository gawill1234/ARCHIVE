#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'misc'
require 'config'
require 'cbed-utils'

results = TestResults.new("collection-broker-export-data 'copy' with query,",
                          "maximum-collections=1 and competing searches.")

tcol = Collection.new('data-export-6-copy')
tcol.delete

bc = Broker_Config.new

# Load my source collection
bcol = base_collection
checker = Export_Checker.new(bcol, tcol, 'dog OR cat OR horse OR mule')
checker.gather_original_counts

system '$TEST_ROOT/tests/collection-broker/tunable.py -c2 -Ncb-tunable-0'

bc.set('log-level' => 'trace', 'maximum-collections' => '1')
msg bc

# Keep the system busy with searches
t1 = Thread.new {
  system '$TEST_ROOT/lib/multi_search.py -p2 -r5 "-ccb-tunable-00 cb-tunable-01"'
}
sleep 60              # Give the parallel searches time to get started

results.add(checker.export, "Export complete.", "Export failed.")

results.add(checker.check_target_counts,
            "Search results counts match.",
            "Search results do not match.")

results.add(t1.value,
            "Competing searches completed.",
            "Competing searches failed to complete.")

results.cleanup_and_exit!
