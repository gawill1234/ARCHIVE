#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Ensure that deleting the dictionary deletes the autocomplete collection')
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

# Setup autocomplete collection
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name)
end

results.add(output_collection.exists?, 'Collection exists', 'Collection does not exist')

dict.delete

results.add(! output_collection.exists?, 'Collection is deleted', 'Collection was not deleted')

results.cleanup_and_exit!(true)
