#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'misc'
require 'config'
require 'cbed-utils'

results = TestResults.new("collection-broker-export-data 'copy' with",
                          "maximum-collections=1 and competing enqueues.")

tcol = Collection.new('data-export-3-copy')
tcol.delete

bc = Broker_Config.new

# Load my source collection
bcol = base_collection
checker = Export_Checker.new(bcol, tcol)
checker.gather_original_counts

bc.set('log-level' => 'trace', 'maximum-collections' => '1')
msg bc
# Keep the system busy with load(s)
t1 = Thread.new {
  system '$TEST_ROOT/tests/collection-broker/tunable.py -c2'
}
sleep 5                   # Give the parallel load time to get started

results.add(checker.export, "Export complete.", "Export failed.")

results.add(checker.check_target_counts,
            "Search results counts match.",
            "Search results do not match.")

results.add(t1.value,
            "Competing enqueues completed.",
            "Competing enqueues failed to complete.")

results.cleanup_and_exit!
