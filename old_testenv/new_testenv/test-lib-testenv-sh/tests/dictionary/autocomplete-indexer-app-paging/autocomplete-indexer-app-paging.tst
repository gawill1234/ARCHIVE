#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Basic test to see if the autocomplete indexer app paging works')
results.need_system_report = false

collection = DictionarySimple.new
results.associate(collection)
collection.setup

app = AutocompleteIndexerApp.new(collection.name)

def page_test(app, results, page_size, expected_contents, expected_iterations)
  total_contents = 0
  iterations = 0

  app.each_page(['title'], :count => page_size) do |container|
    contents = container.xpath('content')
    total_contents += contents.size
    iterations += 1
  end

  results.add_number_equals(expected_contents, total_contents, "content")
  results.add_number_equals(expected_iterations, iterations, "time", :verb => 'Iterated')
end

page_test(app, results,  1, 10, 10)
page_test(app, results,  2, 10,  5)
page_test(app, results,  3, 10,  4)
page_test(app, results,  7, 10,  2)
page_test(app, results, 10, 10,  1)
page_test(app, results, 20, 10,  1)

results.cleanup_and_exit!(true)
