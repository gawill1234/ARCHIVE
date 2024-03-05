#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Basic test to see if counts are returned with suggestions')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

autocomplete.ensure_correct_counts('data1 f', nil, results, [4])
autocomplete.ensure_correct_counts('foo', nil, results, [5, 4, 1])
autocomplete.ensure_correct_counts('bar', nil, results, [3, 2, 1])

results.cleanup_and_exit!(true)
