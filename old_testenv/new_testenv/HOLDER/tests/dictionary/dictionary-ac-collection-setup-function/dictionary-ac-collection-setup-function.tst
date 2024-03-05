#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require "vapi"
require 'make_function_public'

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

make_function_public(vapi, 'dictionary_setup_autocomplete_collection')

results = TestResults.new('Basic test to see if dictionary autocomplete collection setup works')
results.need_system_report = false

collection = Collection.new('ac-datastore-autocomplete')

results.associate(collection)

# Make sure to start with no collection
if collection.exists?
  collection.delete
  results.add(!collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

# Test creating collection
resp = vapi.dictionary_setup_autocomplete_collection(:collection => 'ac-datastore')
error = resp.xpath('//error')
results.add_number_equals(0, error.size, 'error')
results.add(collection.exists?, 'Collection exists', 'Could not create collection')

# Test for existing collection
resp = vapi.dictionary_setup_autocomplete_collection(:collection => 'ac-datastore')
error = resp.xpath('//error')
results.add_number_equals(0, error.size, 'error')

results.add(collection.exists?, 'Collection exists', 'Could not create collection')

# Test when overwriting collection configuration
if collection.exists?
  collection.delete
  results.add(!collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

collection.create('default-push')
if collection.exists?
  results.add(collection.exists?, 'Successfully created base collection', 'Could not create base collection')
end

my_xml = collection.xml
t_e = my_xml.xpath("//vse-index-option[@name='term-expand-dicts']").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

resp = vapi.dictionary_setup_autocomplete_collection(:collection => 'ac-datastore')
error = resp.xpath('//error')
results.add_number_equals(0, error.size, 'error')
my_xml = collection.xml
t_e = my_xml.xpath("//vse-index-option[@name='term-expand-dicts']").first
results.add(t_e, 'Collection has correct configuration', 'Collection does not have correct configuration')

# Test when overwriting collection configuration with custom node
my_xml = collection.xml
t_e = my_xml.xpath("//vse-index-streams/call-function").first
results.add(t_e, 'Expected config present in collection', 'Unexpected configuration!')

resp = vapi.dictionary_setup_autocomplete_collection(
     :collection => 'ac-datastore',
     :vse_index_stream_node => '<vse-index-stream><vse-tokenizer name="literal" /></vse-index-stream>')
error = resp.xpath('//error')
results.add_number_equals(0, error.size, 'error')

my_xml = collection.xml
t_e = my_xml.xpath("//vse-index-streams/vse-index-stream").first
results.add(t_e, 'Expected config present in collection', 'Unexpected configuration!')

restore_internal_function(vapi, 'dictionary_setup_autocomplete_collection')

results.cleanup_and_exit!(true)
