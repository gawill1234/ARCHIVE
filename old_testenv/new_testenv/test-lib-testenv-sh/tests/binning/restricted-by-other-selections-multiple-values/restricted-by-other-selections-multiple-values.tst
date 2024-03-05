#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("Restricting by other selections supports documents",
                          "with fast-indexed nodesets")
results.need_system_report = false

BINNING_XML = <<EOF
<binning-set bs-id='other-selections-id'
             select='$fruit'
             restricted-by='other-selections' />

<binning-set bs-id='regular-id'
             select='$fruit' />
EOF

fruit_collection = MetadataCollection.new(Collection.new(TESTENV.test_name))
fruit_collection.add_document(:fruit => ['apple', 'lemon'])
fruit_collection.add_document(:fruit => ['banana', 'lime'])
fruit_collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, fruit_collection.name, BINNING_XML)
binning_result = search.activate_facet_and_save("other-selections-id", "apple")

binning_result.within("other-selections-id") do |facet_values|
  results.add_set_equals(%w{apple banana lemon lime}, facet_values.labels,
                         'restricted-by="other-selection" facet-value label')
end

binning_result.within("regular-id") do |facet_values|
  results.add_set_equals(%w{apple lemon}, facet_values.labels,
                         'regular facet-value label')
end

results.add_number_equals(1, binning_result.document_count, 'returned document')

results.cleanup_and_exit!(true)