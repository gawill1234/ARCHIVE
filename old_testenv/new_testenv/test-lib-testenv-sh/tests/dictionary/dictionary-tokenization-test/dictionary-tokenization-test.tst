#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'
require 'velocity/example_metadata'

results = TestResults.new('Basic test to see if dictionary tokenization option works')
results.need_system_report = false

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

autocomplete = Autocomplete.new(TESTENV.test_name)

class AutocompleteDictionary
  def setup_and_build(results)
    delete
    create

    yield self

    build
    wait_until_finished(results)
  end
end

#Test turning off tokenization with collection
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(example_metadata.name, :contents => 'hero')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')
correct_suggestions = ['david goodwell', 'gilbert holder', 'gwen wyke', 'simon gold']
autocomplete.ensure_correct_suggestions('g', nil, results, correct_suggestions)

#Test turning off tokenization with file

dict.setup_and_build(results) do |dict|
  dest_path = dict.upload_wildcard_dictionary_input('input')
  dict.add_file_input(dest_path)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')
correct_suggestions = ['steven scott', 'sid halley', 'perry stuart', 'matt shore', 'some more text without a count']
autocomplete.ensure_correct_suggestions('s', nil, results, correct_suggestions)

correct_suggestions = ['sid halley']
autocomplete.ensure_correct_suggestions('h', {:bag_of_words => false}, results, correct_suggestions)

results.cleanup_and_exit!(true)
