#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("We see all top level facets after selecting",
                          "multiple even without any matching documents.")
results.need_system_report = false

BINNING_XML = <<EOF
<binning-set bs-id='other-selections-id'
             select='$location'
             restricted-by='other-selections' />

<binning-set bs-id='regular-id'
             select='$location' />
EOF

collection = MetadataCollection.new(Collection.new(TESTENV.test_name))
results.associate(collection)

collection.add_document(:location => 'USA')
collection.add_document(:location => 'Canada')
collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, collection.name, BINNING_XML)

search.activate_facet_and_save("other-selections-id", "USA")
binning_result = search.activate_facet_and_save("other-selections-id", "Canada")

binning_result.within("other-selections-id") do |facet_values|
  results.add_set_equals(%w{USA Canada}, facet_values.labels,
              "restricted-by='other-selections' facet-value label")
end

binning_result.within("regular-id") do |facet_values|
  results.add_set_equals(%w{}, facet_values.labels,
              "regular facet-value label")
end

results.add_number_equals(0, binning_result.document_count, 'returned document')

results.cleanup_and_exit!(true)
