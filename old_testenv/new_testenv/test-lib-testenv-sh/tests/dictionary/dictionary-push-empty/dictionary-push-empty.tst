#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Basic test to see if dictionary autocomplete collection push works')
results.need_system_report = false

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

autocomplete = Autocomplete.new(TESTENV.test_name)

class AutocompleteDictionary
  def setup_and_build(results)
    remove_all_inputs

    yield self

    build
    wait_until_finished(results)
  end
end

# Put a single word into the dictionary
dict.setup_and_build(results) do |dict|
  dict_path = dict.upload_wildcard_dictionary_input('one-word')
  dict.add_file_input(dict_path)
end

res = output_collection.search('hello')
results.add_number_equals(1, res.xpath('//document').size, "document")

# Then put nothing into the dictionary
dict.setup_and_build(results) do |dict|
  dict_path = dict.upload_wildcard_dictionary_input('no-words')
  dict.add_file_input(dict_path)
end

res = output_collection.search('hello')
results.add_number_equals(0, res.xpath('//document').size, "document")

results.cleanup_and_exit!(true)
