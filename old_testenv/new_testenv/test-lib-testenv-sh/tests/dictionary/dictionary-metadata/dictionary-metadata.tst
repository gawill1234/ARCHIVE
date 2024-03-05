#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require "collection"
require 'autocomplete'
require 'dictionary'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Test to see if the dictionary can use metadata for autocomplete inputs')
results.need_system_report = false

input_collection = DictionaryMetadata.new
results.associate(input_collection)
input_collection.setup

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

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

#Test building without metadata
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
autocomplete.ensure_correct_counts('a', nil, results, [1])
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

#Test building with metadata
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :metadata => 'author')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
correct_metadata = [
  {'author' => [['Alice', 1]]}
]
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)
autocomplete.ensure_correct_metadata('a', nil, results, correct_metadata)

#Test building with metadata and count
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :metadata => 'author', :count => 'count')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
correct_metadata = [
  {'author' => [['Alice', 1]]}
]
autocomplete.ensure_correct_counts('a', nil, results, [3])
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)
autocomplete.ensure_correct_metadata('a', nil, results, correct_metadata)

#Test building with multiple metadata values
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :contents => 'author', :metadata => 'title', :count => 'count')
end

correct_suggestions = ['otto']
correct_metadata = [
  {'title' => [['omega', 1], ['omicron', 1]]}
]
autocomplete.ensure_correct_suggestions('o', nil, results, correct_suggestions)
autocomplete.ensure_correct_metadata('o', nil, results, correct_metadata)

#Test building with multiple metadata contents
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :contents => 'author', :metadata => "title\ngenre", :count => 'count')
end

correct_suggestions = ['otto']
correct_metadata = [
  {'title' => [['omega', 1], ['omicron', 1]], 'genre' => [['Horror', 2]]}
]
autocomplete.ensure_correct_suggestions('o', nil, results, correct_suggestions)
autocomplete.ensure_correct_metadata('o', nil, results, correct_metadata)

#Test building with multiple contents
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :contents => "author\ntitle", :metadata => "genre", :count => 'count')
end

correct_suggestions = ['otto', 'omega', 'omicron']
correct_metadata = [
  {'genre' => [['Horror', 2]]},
  {'genre' => [['Horror', 1]]},
  {'genre' => [['Horror', 1]]}
]
autocomplete.ensure_correct_suggestions('o', nil, results, correct_suggestions)
autocomplete.ensure_correct_metadata('o', nil, results, correct_metadata)

results.cleanup_and_exit!(true)
