#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Basic test to see if dictionary autocomplete output tokenization works')
results.need_system_report = false

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)

input_collection = DictionaryCanonical.new
results.associate(input_collection)
input_collection.setup

# Test creating collection
dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

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

msg('Test that string matches middle of tokenized phrase by default')
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'email')
end
results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['joe@blah.com']
autocomplete.ensure_correct_counts('blah', nil, results, [2])
autocomplete.ensure_correct_suggestions('blah', nil, results, correct_suggestions)

msg("Test that string does not match middle of tokenized phrase if output tokenizer is 'literal'")
dict.setup_and_build(results) do |dict|
  dict.set_to_autocomplete_vis_node_output
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'email')
end

correct_suggestions = []
autocomplete.ensure_correct_counts('blah', nil, results, [])
autocomplete.ensure_correct_suggestions('blah', nil, results, correct_suggestions)

results.cleanup_and_exit!(true)
