#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require "vapi"
require 'dictionary_collections'
require 'dictionary'
require 'velocity/example_metadata'

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

results = TestResults.new('Basic test to see if dictionary setup correctly adds the rights-function attribute')
results.need_system_report = false

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
example_metadata = ExampleMetadata.new()
example_metadata.ensure_correctness

# Make sure to start with no collection
if output_collection.exists?
  output_collection.delete
  results.add(!output_collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

# Test creating collection
dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

msg('There should be no attribute if security is set to "none"')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

msg('There should be no attribute if security is set to "preemptive"')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'preemptive', :rights => 'foo')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

msg('Attribute should be set to default if only "full security" is set')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'full')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(t_e.value == 'util-groups-for-user', 'Expected config present in collection', 'Unexpected configuration!')

dict.delete
dict.create

msg('Attribute should be set to dictionary\'s rights-function when "full security" is set')
dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'full')
dict.set_rights_function('foo')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(t_e.value == 'foo', 'Expected config present in collection', 'Unexpected configuration!')

msg('If dictionary has attribute but is not set to "full security", source should not have attribute')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero')
dict.set_rights_function('foo')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

msg('Attribute should be set if all inputs are set to full security')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'full')
dict.add_autocomplete_collection_input('example-metadata', :contents => 'title', :security => 'full')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(t_e.value == 'util-groups-for-user', 'Expected config present in collection', 'Unexpected configuration!')

msg('Attribute should be set if all inputs are set to full security and dict has @rights-function')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'full')
dict.add_autocomplete_collection_input('example-metadata', :contents => 'title', :security => 'full')
dict.set_rights_function('foo')
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(t_e.value == 'foo', 'Expected config present in collection', 'Unexpected configuration!')

msg('Dictionary should return an error if inputs have inconsistent security')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'full')
dict.add_autocomplete_collection_input('example-metadata', :contents => 'title')
dict.build
dict.wait_until_finished(results, false)

error = dict.errors
results.add_number_equals(1, error.size, 'error')
errorid = error.xpath('//error/@id').first
results.add_equals('DICTIONARY_INPUTS_INCONSISTENT_SECURITY', errorid.value, 'expected error')

msg('Dictionary should return an error if inputs have inconsistent security (preemptive security case)')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero', :security => 'full')
dict.add_autocomplete_collection_input('example-metadata', :contents => 'title', :security => 'preemptive', :rights => 'foo')
dict.build
dict.wait_until_finished(results, false)

error = dict.errors
results.add_number_equals(1, error.size, 'error')
errorid = error.xpath('//error/@id').first
results.add_equals('DICTIONARY_INPUTS_INCONSISTENT_SECURITY', errorid.value, 'expected error')

msg('Dictionary should not have an error if inputs have mixed "no security" and "preemptive security"')
dict.delete
dict.create

dict.add_autocomplete_collection_input('example-metadata', :contents => 'hero')
dict.add_autocomplete_collection_input('example-metadata', :contents => 'title', :security => 'preemptive', :rights => 'foo')
dict.build
dict.wait_until_finished(results)

my_xml = vapi.repository_get(:element => 'source', :name => TESTENV.test_name + '-autocomplete')
t_e = my_xml.xpath("/source/@rights-function").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

results.cleanup_and_exit!(true)
