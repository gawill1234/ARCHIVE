#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-export/'

require 'misc'
require 'cbed-utils'

results = TestResults.new("collection-broker-export-data 'move' with a query",
                          "and 'meta' for the source specifying different",
                          "paths for the live and staging directories.")

scol = Collection.new('data-export-move-9-source')
scol.delete

tcol = Collection.new('data-export-move-9-copy')
tcol.delete

# Load my base collection
bcol = base_collection

# Ugly. This should be in a library somewhere.
emfb = Collection.new('example-metadata').filebase
path = emfb[0..emfb.index('data')+4] + 'testing/' + scol.name

# This is the "standard" form, typical for REST calls.
meta = '<vse-meta>
<vse-meta-info name="live-crawl-dir">%s/live</vse-meta-info>
<vse-meta-info name="staging-crawl-dir">%s/staging</vse-meta-info>
</vse-meta>' % [path, path]

# Due to bug 22647, we need to use the SOAP form of vse-meta.
meta = '<vse-meta><vse-meta-info>
  <live-crawl-dir>%s/live</live-crawl-dir>
  <staging-crawl-dir>%s/staging</staging-crawl-dir>
</vse-meta-info></vse-meta>' % [path, path]

results.add(copy_collection(bcol, scol, :destination_collection_meta => meta),
            "Source collection in place (export complete).",
            "Source collection setup failed.")

vse_meta_info = scol.xml.xpath('/vse-collection/vse-meta/vse-meta-info')
results.add(vse_meta_info.length == 2,
            "Two vse-meta-info nodes found for the source collection.",
            "Unexpected vse-meta-info nodes for #{scol.name}: #{vse_meta_info}")

checker = Export_Checker.new(scol, tcol, 'dog OR cat OR horse OR mule')
checker.gather_original_counts
results.add(checker.export(:move => true), "Export complete.", "Export failed.")
results.add(checker.check_target_counts,
            "Search results counts match.",
            "Search results do not match.")

vse_meta_info = tcol.xml.xpath('/vse-collection/vse-meta/vse-meta-info')
results.add(vse_meta_info.length == 0,
            "No vse-meta-info nodes found for the target collection.",
            "Unexpected vse-meta-info nodes for #{tcol.name}: #{vse_meta_info}")

results.cleanup_and_exit!
