#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'vapi'
require 'make_function_public'
require 'velocity/example_metadata'

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
older_velocity = (ENV['VIVVERSION'].to_f < 8.2)
if older_velocity
  make_function_public(vapi, 'dictionary_read_from_collection')
end

results = TestResults.new('Basic test of reading from a collection via the index axl app')
results.need_system_report = false

collection = DictionarySimple.new
results.associate(collection)

example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

# Make sure to start with no collection
if !collection.exists?
  collection.setup
  #collection.delete
  #results.add(!collection.exists?, 'Successfully deleted collection', 'Could not delete collection')
end

# Test for response from collection
response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => collection.name, :contents => "title\nsnippet"})
results.add(response, 'Expected response from collection', 'Unexpected response!')
container = response.xpath('results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(10, documents.size, 'document element')

# Test for response from collection with acls
response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => collection.name, :contents => "title\nsnippet", :acls => "4\n5"})
results.add(response, 'Expected response from collection', 'Unexpected response!')
container = response.xpath('results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(4, documents.size, 'document element')

# Test for response from collection with count
response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => collection.name, :contents => "title\nsnippet", :count => 2})
results.add(response, 'Expected response from collection', 'Unexpected response!')
container = response.xpath('results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(2, documents.size, 'document element')

# Test for response from collection with metadata
response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => example_metadata.name, :contents => "title", :metadata => "hero"})
results.add(response, 'Expected response from collection', 'Unexpected response!')
container = response.xpath('results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(10, documents.size, 'document element')

documents.each do |doc|
  contents = doc.xpath('content[@name="title"]')
  results.add_number_equals(1, contents.size, 'content element')

  contents = doc.xpath('content[@name="year"]')
  results.add_number_equals(0, contents.size, 'content element')
end

# Test for response from remote collection
response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => example_metadata.name, :contents => "title", :metadata => "hero", :host => 'localhost', :port => TESTENV.query_service_port, :username => TESTENV.user, :password => TESTENV.password})
results.add(response, 'Expected response from collection', 'Unexpected response!')
container = response.xpath('results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(10, documents.size, 'document element')

documents.each do |doc|
  contents = doc.xpath('content[@name="title"]')
  results.add_number_equals(1, contents.size, 'content element')

  contents = doc.xpath('content[@name="year"]')
  results.add_number_equals(0, contents.size, 'content element')
end

if older_velocity
  restore_internal_function(vapi, 'dictionary_read_from_collection')
else
  # Test for response when passing empty 'and' operator
  response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => collection.name, :contents => "title\nsnippet", "query-object" => '<operator logic="and"/>'})
  results.add(response, 'Expected response from collection', 'Unexpected response!')
  container = response.xpath('results')
  results.add_number_equals(1, container.size, 'result element')

  documents = container.xpath('document')
  results.add_number_equals(10, documents.size, 'document element')

  # Test for response when passing empty 'and' operator
  response = vapi.dictionary_read_from_collection({:dictionary => TESTENV.test_name, :collection => collection.name, :contents => "title\nsnippet", :count => 2, "query-object" => '<operator logic="and"><term field="query" str="whiskey"/></operator>'})
  results.add(response, 'Expected response from collection', 'Unexpected response!')
  container = response.xpath('results')
  results.add_number_equals(1, container.size, 'result element')

  documents = container.xpath('document')
  results.add_number_equals(2, documents.size, 'document element')
end

results.cleanup_and_exit!(true)
