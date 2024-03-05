#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'misc'
require 'config'
require 'cbed-utils'

results = TestResults.new("collection-broker-export-data 'move' all,",
                          "with collection broker set to no memory available.")

scol = Collection.new('data-export-move-7-source')
scol.delete
tcol = Collection.new('data-export-move-7-target')
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

msg "Tell the collection broker there is no available memory."
bc.set('log-level' => 'trace',
       'always-allow-one-collection' => false,
       'check-memory-usage-time' => 0.1,
       'minimum-free-memory' => (256*1024*1024*1024),
       'overcommit-factor' => 0.0001)
msg bc

results.add(checker.export(:move => true), "Export complete.", "Export failed.")

msg "Reset collection broker config to the defaults (to allow searches)."
bc.set

results.add(checker.check_target_counts,
            "Search results counts match.",
            "Search results do not match.")

results.cleanup_and_exit!
