#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'

results = TestResults.new('Test to see if autocomplete query \'bag-of-words\' param works')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

autocomplete.ensure_correct_suggestions('data f', nil, results, [])
autocomplete.ensure_correct_suggestions('data f', {:bag_of_words => true}, results, ['foo data'])

results.cleanup_and_exit!(true)
