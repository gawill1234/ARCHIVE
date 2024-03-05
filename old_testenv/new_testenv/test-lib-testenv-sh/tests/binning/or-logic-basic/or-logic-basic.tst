#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

results = TestResults.new("Can select multiple facet-values with disjoint",
                          "document content values.")
results.need_system_report = false

BINNING_XML = <<EOF
<binning-set bs-id='or-logic-id'
             select='$fruit'
             logic='or' />
EOF

collection = MetadataCollection.new(Collection.new(TESTENV.test_name))
results.associate(collection)

collection.add_document(:fruit => 'apple')
collection.add_document(:fruit => 'banana')
collection.add_document(:fruit => 'coconut')
collection.save!

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

search = Binning::Search.new(vapi, collection.name, BINNING_XML)

binning_result = search.activate_facet_and_save("or-logic-id", "apple")
results.add_set_equals(%w{apple}, binning_result.content_values("fruit"),
                       'returned document')

binning_result = search.activate_facet_and_save("or-logic-id", "banana")
results.add_set_equals(%w{apple banana}, binning_result.content_values("fruit"),
                       'returned document')

results.cleanup_and_exit!(true)
