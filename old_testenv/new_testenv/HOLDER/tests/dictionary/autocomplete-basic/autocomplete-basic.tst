#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Basic test to see if autocomplete query works')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

correct_suggestions = ['data1 bar', 'bar data1', 'foo bar data2']
autocomplete.ensure_correct_suggestions('b', nil, results, correct_suggestions)

results.cleanup_and_exit!(true)
