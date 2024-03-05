#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary'

results = TestResults.new('Basic test to see if dictionary building works')
results.need_system_report = false

dict = Dictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

dest_path = dict.upload_wildcard_dictionary_input('input')
dict.add_file_input(dest_path)
dict.limit_to_wildcard_output

dict.build
dict.wait_until_finished(results)

dict.sort_and_save_built_wildcard_dictionary('test_dict')

files_are_same = FileUtils.compare_file('correct_dict', 'test_dict')
results.add(files_are_same, "Wildcard dictionary matches", "Wildcard dictionary does not match")

results.cleanup_and_exit!(true)
