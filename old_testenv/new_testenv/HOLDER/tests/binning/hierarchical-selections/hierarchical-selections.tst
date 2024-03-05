#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("Can select the child bin of a hierarchical binning-set",
                          "without passing in all of its parents' binning-state",
                          "tokens as well.")
results.need_system_report = false

BINNING_XML = <<EOF
<binning-set bs-id='hierarchical-id'
             select='$location'
             logic='or' >
  <binning-tree delimiter='>'/>
</binning-set>
EOF

collection = MetadataCollection.new(TESTENV.test_name)
results.associate(collection)

collection.add_document(:location => 'USA>PA')
collection.add_document(:location => 'US')
collection.add_document(:location => 'Mexico>Oaxaca')
collection.add_document(:location => 'Mexico>Tobasco')
collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, collection.name, BINNING_XML)

search.activate_facet("hierarchical-id", "USA")
binning_result = search.activate_facet_and_save("hierarchical-id", "PA")

binning_result.within("hierarchical-id") do |facet_values|
  results.add_set_equals(%w{USA}, facet_values.active_labels,
                         "top level active label")

  facet_values.within("USA") do |facet_values|
      results.add_set_equals(%w{PA}, facet_values.active_labels,
                             "child active label")
  end
end

results.add_set_equals(%w{USA>PA}, binning_result.content_values("location"),
                       'document')

results.cleanup_and_exit!(true)
