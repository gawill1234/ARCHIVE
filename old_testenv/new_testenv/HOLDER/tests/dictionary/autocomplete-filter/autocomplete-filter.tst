#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'autocomplete_collections'
require 'autocomplete_filters'

results = TestResults.new('Basic test to see if autocomplete query filtering works')
results.need_system_report = false

collection = AutocompleteDataCollection.new
results.associate(collection)
collection.setup

autocomplete = Autocomplete.new(collection.autocomplete_name)

foofilter = FooFilter.new
barfilter = BarFilter.new

results.associate(foofilter)
results.associate(barfilter)

def test_filter(autocomplete, filter, results, correct_suggestions)
  filter.setup

  autocomplete.ensure_correct_suggestions('data', {:filter => filter.name}, results, correct_suggestions)
  autocomplete.ensure_correct_suggestions('data', {:filter => filter.name, :bag_of_words => true}, results, correct_suggestions)
end

test_filter(autocomplete, foofilter, results, ['data1 bar', 'bar data1'])
test_filter(autocomplete, barfilter, results, ['foo data', 'data1 foo'])

results.cleanup_and_exit!(true)
