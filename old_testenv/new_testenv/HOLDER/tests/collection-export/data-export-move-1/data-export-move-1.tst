#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'misc'
require 'config'
require 'cbed-utils'

results = TestResults.new("collection-broker-export-data 'move' all.")

scol = Collection.new('data-export-move-1-source')
scol.delete
tcol = Collection.new('data-export-move-1-target')
tcol.delete

bc = Broker_Config.new

msg "Reset collection broker config to the defaults (to allow searches)."
bc.set

# Load my source collection
bcol = base_collection
results.add(copy_collection(bcol, scol),
            "Source collection in place (export complete).",
            "Source collection setup failed.")

checker = Export_Checker.new(scol, tcol)

# Since we're going to modify the source, gather expected counts in advance.
checker.gather_original_counts
results.add(checker.export(:move => true), "Export complete.", "Export failed.")

msg "Reset collection broker config to the defaults (to allow searches)."
bc.set

results.add(checker.check_target_counts,
            "Search results counts match.",
            "Search results do not match.")

results.cleanup_and_exit!
