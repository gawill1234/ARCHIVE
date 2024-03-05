#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("Only the expected disjoint documents are returned",
                          "when performing or-faceting on hierarchical facets.")
results.need_system_report = false

BINNING_XML = <<XML
<binning-set bs-id='or-logic-id'
             select='$location'
             logic='or'>
  <binning-tree delimiter='>' />
</binning-set>
XML

collection = MetadataCollection.new(TESTENV.test_name)
results.associate(collection)

collection.add_document(:location => "USA>PA")
collection.add_document(:location => "USA>NY")
collection.add_document(:location => "Canada>Ontario")
collection.add_document(:location => "Mexico>Oaxaca")
collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

msg("Step 1: Same parent, same level (activate the 'USA' and 'Canada' facets)")
search = Binning::Search.new(vapi, collection.name, BINNING_XML)

search.activate_facet_and_save("or-logic-id", "USA")
binning_result = search.activate_facet_and_save("or-logic-id", "Canada")

results.add_set_equals(%w{USA>PA USA>NY Canada>Ontario},
                       binning_result.content_values("location"),
                       'document')

msg("Step 2: Different parent, same level (activate the 'USA>PA' and 'Canada>Ontario' facets)")
search = Binning::Search.new(vapi, collection.name, BINNING_XML)
search.activate_facet("or-logic-id", "USA")
search.activate_facet_and_save("or-logic-id", "PA")
search.activate_facet("or-logic-id", "Canada")
binning_result = search.activate_facet_and_save("or-logic-id", "Ontario")

results.add_set_equals(%w{USA>PA Canada>Ontario},
                       binning_result.content_values("location"),
                       'document')

msg("Step 3: Different parent, different level (activate the 'USA>PA' and 'Canada' facets)")
search = Binning::Search.new(vapi, collection.name, BINNING_XML)

search.activate_facet("or-logic-id", "USA")
search.activate_facet_and_save("or-logic-id", "PA")
binning_result = search.activate_facet_and_save("or-logic-id", "Canada")
results.add_set_equals(%w{USA>PA Canada>Ontario},
                       binning_result.content_values("location"),
                       'document')
