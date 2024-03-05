#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Basic test to see if the autocomplete indexer app returns metadata')
results.need_system_report = false

collection = DictionaryMetadata.new
results.associate(collection)
collection.setup

app = AutocompleteIndexerApp.new(collection.name)

Suggestion = Struct.new(:title, :metadata)
expected_suggs = Array.new
expected_suggs << Suggestion.new('alpha', ['Alice'])
expected_suggs << Suggestion.new('beta', ['Bob', 'Betty'])
expected_suggs << Suggestion.new('omega', ['Otto'])
expected_suggs << Suggestion.new('omicron', ['Otto'])

document_count = 0
app.each_document(['title'], :metadata => ['author']) do |doc, i|
  expected = expected_suggs[i]

  title_contents = doc.xpath('content[@name = "title"]')
  results.add_number_equals(1, title_contents.size, 'content[@name = "title"] element')

  meta_contents = doc.xpath('content[@name != "title"]')
  results.add_number_equals(expected.metadata.size, meta_contents.size, 'content[@name != "title"] element')

  meta_contents.each_with_index do |meta_content, j|
    expected_meta = expected.metadata[j]

    results.add_equals('author', meta_content['name'], 'meta content name')
    results.add_equals(expected_meta, meta_content.content, 'meta content value')
  end

  document_count += 1
end

results.add_number_equals(4, document_count, 'document element')

results.cleanup_and_exit!(true)
