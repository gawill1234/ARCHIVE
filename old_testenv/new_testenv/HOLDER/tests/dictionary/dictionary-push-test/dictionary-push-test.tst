#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'
require 'velocity/example_metadata'

results = TestResults.new('Basic test to see if dictionary autocomplete collection push works')
results.need_system_report = false

input_collection = DictionarySimple.new
results.associate(input_collection)
input_collection.setup

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

autocomplete = Autocomplete.new(TESTENV.test_name)

class AutocompleteDictionary
  def setup_and_build(results)
    remove_all_inputs

    yield self

    set_tokenization(true)
    build
    wait_until_finished(results)
  end
end

#Test pushing to ac collection
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(example_metadata.name, :contents => 'hero')
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')
correct_suggestions = ['halley', 'hawkins', 'henry', 'hughes']
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test pushing to ac collection with existing data
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name)
  dict.set_tokenization(true)
end

correct_suggestions = ['hotel']
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test pushing to ac collection with empty content nodes
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(example_metadata.name)
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')
correct_suggestions = ['horse', 'horses', 'have', 'halley']
autocomplete.ensure_correct_suggestions('h', {:num => 4}, results, correct_suggestions)

results.cleanup_and_exit!(true)
