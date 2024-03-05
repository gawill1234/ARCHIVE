#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'misc'
require 'config'
require 'cbed-utils'

results = TestResults.new("collection-broker-export-data 'copy' (simple).")

tcol = Collection.new('data-export-1-copy')
tcol.delete

bc = Broker_Config.new
bc.set

# Load my source collection
bcol = base_collection
checker = Export_Checker.new(bcol, tcol)

bcol.broker_start
results.add(checker.export, "Export complete.", "Export failed.")

checker.gather_original_counts
results.add(checker.check_target_counts,
            "Search results counts match.",
            "Search results do not match.")

results.cleanup_and_exit!
