#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Basic test to ensure that the correct suggestions are returned when rights are provided')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

autocomplete.ensure_correct_suggestions('foo', nil, results, ['foo data', 'data1 foo', 'foo bar data2'])
autocomplete.ensure_correct_suggestions('foo', {:rights => "1"}, results, ['foo data'])
autocomplete.ensure_correct_suggestions('foo', {:rights => "1\n2"}, results, ['foo data', 'data1 foo'])
autocomplete.ensure_correct_suggestions('foo', {:rights => ""}, results, [])

results.cleanup_and_exit!(true)
