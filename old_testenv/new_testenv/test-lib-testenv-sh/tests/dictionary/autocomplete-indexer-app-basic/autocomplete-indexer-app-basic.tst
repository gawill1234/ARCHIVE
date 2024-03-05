#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Basic test to see if the autocomplete indexer app works')
results.need_system_report = false

collection = DictionarySimple.new
results.associate(collection)
collection.setup

app = AutocompleteIndexerApp.new(collection.name)
index_data = app.get_data(['title'], :count => 10)

exceptions = index_data.xpath('//exception')
results.add_number_equals(0, exceptions.size, 'exception')

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(10, documents.size, 'document element')

documents.each do |doc|
  contents = doc.xpath('content')
  results.add_number_equals(1, contents.size, 'content element')

  content = contents.first
  results.add_equals('title', content['name'], 'content name')
end

next_page = container.xpath('r')
results.add_number_equals(1, next_page.size, 'r element')

results.cleanup_and_exit!(true)
