#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/binning'

require 'misc'
require 'binning'
require 'metadata_collection'

BINNING_XML = <<END
<binning-set bs-id='other-selections-id' select='$variety'
  restricted-by='other-selections' />
<binning-set bs-id='regular-id' select='$variety' />
END

collapse_settings = {"collapse-xpath" => "$fruit",
                     "collapse-num" => "10",
                     "collapse-binning" => "true"}

#0. Initialize collectionand other test configuration
test_results = TestResults.new("Test that we prevent using collapsed binning",
                               "alongside restricted-by='other-selections' binning.")
test_results.need_system_report = false
vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
collection = MetadataCollection.new(TESTENV.test_name)
test_results.associate(collection)

collection.add_document({:variety => "Granny Smith", :fruit => "apple"})
collection.add_document({:title => "Pink Lady", :fruit => "apple"})
collection.add_document({:title => "Cavendish", :fruit => "banana"})
collection.save!

search = Binning::Search.new(vapi, collection.name, BINNING_XML)

result = search.activate_facet_and_save("other-selections-id", "Granny Smith",
                                        collapse_settings)

expected_errors = %w{SEARCH_ENGINE_COLLAPSED_BINNING_INCOMPATIBLE_WITH_OTHER_SELECTIONS}
actual_errors = result.ids_for_errors
test_results.add_set_equals(expected_errors, actual_errors, "error id")

test_results.cleanup_and_exit!
