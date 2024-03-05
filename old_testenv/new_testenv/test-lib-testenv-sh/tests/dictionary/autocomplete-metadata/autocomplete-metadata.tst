#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Basic test to see if metadata is returned with suggestions')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

righto = [
  {'author' => [['Sally', 1]]}
]
autocomplete.ensure_correct_metadata('data1 f', nil, results, righto)

righto = [
  {'author' => [['Joe', 1], ['Sally', 1]]},
  {'author' => [['Sally', 1]]},
  {'author' => [['Joe', 1]]}
]
autocomplete.ensure_correct_metadata('foo', nil, results, righto)

righto = [
  {},
  {'image' => [['pic.jpg', 1]], 'url' => [['http://example.com', 1]]},
  {'author' => [['Joe', 1]]}
]
autocomplete.ensure_correct_metadata('bar', nil, results, righto)

results.cleanup_and_exit!(true)
