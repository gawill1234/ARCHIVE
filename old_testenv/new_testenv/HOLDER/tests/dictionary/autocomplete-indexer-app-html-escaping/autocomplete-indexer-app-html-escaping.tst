#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Basic test to see if the autocomplete indexer app works')
results.need_system_report = false

collection = DictionaryHTMLEscaping.new
results.associate(collection)
collection.setup

app = AutocompleteIndexerApp.new(collection.name)
index_data = app.get_data(['name'], :count => 10)

documents = index_data.xpath('/vce/results/document')
results.add_number_equals(7, documents.size, 'document element')

documents.each do |doc|
  contents = doc.xpath('content')
  results.add_number_equals(2, contents.size, 'content element')

  content1 = contents[0]
  content2 = contents[1]
  results.add_equals(content1.content, content2.content, 'content value')
end

results.cleanup_and_exit!(true)
