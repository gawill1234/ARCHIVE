#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("Restricting by other selections supports",
                          "hierarchical facets.")
results.need_system_report = false

BINNING_XML = <<EOF
<binning-set bs-id='other-selections-id'
             select='$location'
             restricted-by='other-selections'>
  <binning-tree delimiter='>' />
</binning-set>

<binning-set bs-id='regular-id'
             select='$location'>
  <binning-tree delimiter='>' />
</binning-set>
EOF

collection = MetadataCollection.new(TESTENV.test_name)
results.associate(collection)

collection.add_document(:location => 'USA>PA')
collection.add_document(:location => 'USA>CA')
collection.add_document(:location => 'Canada>Ontario')
collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, collection.name, BINNING_XML)
binning_result = search.activate_facet_and_save("other-selections-id", "USA")

binning_result.within("other-selections-id") do |facet_values|
  results.add_set_equals(%w{Canada USA}, facet_values.labels,
                         "top level restricted-by='other-selection' parent "\
                         "facet-value label")

  facet_values.within("USA") do |facet_values|
    results.add_set_equals(%w{CA PA}, facet_values.labels,
                           "restricted-by='other-selection' child facet-value "\
                           "label")
  end

  facet_values.within("Canada") do |facet_values|
    results.add_set_equals(%w{}, facet_values.labels,
                           "restricted-by='other-selection' child facet-value "\
                           "label")
  end
end

binning_result.within("regular-id") do |facet_values|
  results.add_set_equals(%w{USA}, facet_values.labels,
                         "regular parent facet-value label")

  facet_values.within("USA") do |facet_values|
    results.add_set_equals(%w{CA PA}, facet_values.labels,
                           "regular child facet-value label")
  end
end

results.add_number_equals(2, binning_result.document_count, 'returned document')

results.cleanup_and_exit!(true)
