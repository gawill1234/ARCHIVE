#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

test_results = TestResults.new(
"Restrict a binning set by other binning selections, but not its own"
)
test_results.need_system_report = false

BINNING_XML = <<EOF
<binning-set bs-id='other-selections-id'
             select='$fruit'
             restricted-by='other-selections' />

<binning-set bs-id='regular-id'
             select='$fruit' />
EOF

fruit_collection = MetadataCollection.new(Collection.new(TESTENV.test_name))
test_results.associate(fruit_collection)
fruit_collection.add_document(:fruit => 'apple')
fruit_collection.add_document(:fruit => 'banana')
fruit_collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, fruit_collection.name, BINNING_XML)

binning_result = search.activate_facet_and_save("other-selections-id", "apple")

binning_result.within("other-selections-id") do |facet_value|
  test_results.add_set_equals(%w{apple banana}, facet_value.labels,
                              "unrestricted facet-value label")
end

binning_result.within("regular-id") do |facet_value|
  test_results.add_set_equals(%w{apple}, facet_value.labels,
                              "restricted facet-value label")
end

test_results.add_number_equals(1, binning_result.document_count,
                               "returned document")

test_results.cleanup_and_exit!(true)
