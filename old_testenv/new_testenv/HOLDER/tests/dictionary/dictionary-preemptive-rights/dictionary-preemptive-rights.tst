#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require "collection"
require 'autocomplete'
require 'dictionary'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Test to see if the autocomplete indexer app will respect rights')
results.need_system_report = false

input_collection = DictionarySimple.new
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

#Test building with no security
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name, :security => 'none')
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

correct_suggestions = ['hotel']
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test building with no security or tokenization
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name, :security => 'none')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha charlie echo golf india kilo mike oscar quebec sierra']
autocomplete.ensure_correct_suggestions('alpha c', nil, results, correct_suggestions)

correct_suggestions = ['alpha bravo charlie delta echo foxtrot golf hotel india juliet']
autocomplete.ensure_correct_suggestions('hotel i', nil, results, correct_suggestions)

#Test building with preemptive security
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name, :security => 'preemptive', :rights => "4\n5")
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

correct_suggestions = []
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test building with preemptive security and no tokenization
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name, :security => 'preemptive', :rights => "4\n5")
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha charlie echo golf india kilo mike oscar quebec sierra']
autocomplete.ensure_correct_suggestions('alpha c', nil, results, correct_suggestions)

correct_suggestions = []
autocomplete.ensure_correct_suggestions('hotel i', nil, results, correct_suggestions)

results.cleanup_and_exit!(true)
