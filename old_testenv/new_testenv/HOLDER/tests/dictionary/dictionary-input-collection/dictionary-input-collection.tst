#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Test to see if dictionary building from a collection works')
results.need_system_report = false

collection = DictionarySimple.new
results.associate(collection)
collection.setup

dict = Dictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

dict.add_collection_input(collection.name)
dict.limit_to_wildcard_output

dict.build
dict.wait_until_finished(results)

dict.sort_and_save_built_wildcard_dictionary('test_dict')

files_are_same = FileUtils.compare_file('correct_dict', 'test_dict')
results.add(files_are_same, "Wildcard dictionary matches", "Wildcard dictionary does not match")

results.cleanup_and_exit!(true)
