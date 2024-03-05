#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Basic test to see if dictionary autocomplete collection setup works')
results.need_system_report = false

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
input_collection = DictionarySimple.new
results.associate(input_collection)
input_collection.setup

# Make sure to start with no collection
if output_collection.exists?
  output_collection.delete
  results.add(!output_collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

# Test creating collection
dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

dict.add_collection_input(input_collection.name)
dict.build
dict.wait_until_finished(results)

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

# Test for existing collection
dict.build
dict.wait_until_finished(results)
results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

# Test when overwriting collection configuration
if output_collection.exists?
  output_collection.delete
  results.add(!output_collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

output_collection.create('default-push')
if output_collection.exists?
  results.add(output_collection.exists?, 'Successfully created base collection', 'Could not create base collection')
end

my_xml = output_collection.xml
t_e = my_xml.xpath("//vse-index-option[@name='term-expand-dicts']").first
results.add(! t_e, 'Expected config present in collection', 'Unexpected configuration!')

dict.build
dict.wait_until_finished(results)

my_xml = output_collection.xml
t_e = my_xml.xpath("//vse-index-option[@name='term-expand-dicts']").first
results.add(t_e, 'Collection has correct configuration', 'Collection does not have correct configuration')

# Test when overwriting collection configuration with custom node
my_xml = output_collection.xml
t_e = my_xml.xpath("//vse-index-streams/call-function").first
results.add(t_e, 'Expected config present in collection', 'Unexpected configuration!')

dict.set_to_autocomplete_vis_node_output
dict.build
dict.wait_until_finished(results)

my_xml = output_collection.xml
t_e = my_xml.xpath("//vse-index-streams/vse-index-stream").first
results.add(t_e, 'Expected config present in collection', 'Unexpected configuration!')

results.cleanup_and_exit!(true)
