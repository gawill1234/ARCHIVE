#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'dictionary'

# Note that we can't test the memory usage here, so this isn't a true
# test of the change. Check the bug for further information.
results = TestResults.new('Ensure the number of documents to read ',
                          'from a collection at a time can be set (bug 27348)')
results.need_system_report = false

collection = DictionaryLarge.new
results.associate(collection)
collection.setup

dict = Dictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

dict.add_collection_input(collection.name, :num_to_read => 1)
dict.limit_to_wildcard_output

dict.build
dict.wait_until_finished(results)

dict.sort_and_save_built_wildcard_dictionary('test_dict')

files_are_same = FileUtils.compare_file('correct_dict', 'test_dict')
results.add(files_are_same, "Wildcard dictionary matches", "Wildcard dictionary does not match")

results.cleanup_and_exit!(true)
