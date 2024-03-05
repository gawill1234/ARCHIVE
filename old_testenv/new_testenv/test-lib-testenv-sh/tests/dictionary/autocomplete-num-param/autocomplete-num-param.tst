#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Basic test to see if autocomplete query \'num\' param works')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

correct_suggestions = ['data1 bar']
autocomplete.ensure_correct_suggestions('b', {:num => 1}, results, correct_suggestions)

results.cleanup_and_exit!(true)
