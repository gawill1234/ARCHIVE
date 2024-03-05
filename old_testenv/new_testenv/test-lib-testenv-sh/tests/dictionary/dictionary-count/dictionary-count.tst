#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require "collection"
require 'autocomplete'
require 'dictionary'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Test to see if the dictionary can use count attribute for autocomplete inputs')
results.need_system_report = false

input_collection = DictionarySimple.new
results.associate(input_collection)
input_collection.setup

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

autocomplete = Autocomplete.new(TESTENV.test_name)

class AutocompleteDictionary
  def setup_and_build(results)
    delete
    create

    yield self

    build
    wait_until_finished(results)
  end
end

#Test building without count
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete.ensure_correct_counts('a', nil, results, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

# Need consitent ranking
correct_suggestions = ['alpha bravo charlie delta echo foxtrot golf hotel india juliet', 'alpha hotel oscar victor charlie juliet quebec xray echo lima']
autocomplete.ensure_correct_counts('h', nil, results, [1, 1])
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test building with count
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :count => 'count')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete.ensure_correct_counts('a', nil, results, [10, 9, 8, 7, 6, 5, 4, 3, 2, 1])

correct_suggestions = ['alpha bravo charlie delta echo foxtrot golf hotel india juliet', 'alpha hotel oscar victor charlie juliet quebec xray echo lima']
autocomplete.ensure_correct_counts('h', nil, results, [9, 3])
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test that count acts as a multiplier
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none')
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
autocomplete.ensure_correct_counts('a', nil, results, [19])
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

correct_suggestions = ['hotel']
autocomplete.ensure_correct_counts('h', nil, results, [2])
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :count => 'count')
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['alpha']
autocomplete.ensure_correct_counts('a', nil, results, [145])
autocomplete.ensure_correct_suggestions('a', nil, results, correct_suggestions)

correct_suggestions = ['hotel']
autocomplete.ensure_correct_counts('h', nil, results, [12])
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test building with non-existent count
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :count => 'notarealcontent')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete.ensure_correct_counts('a', nil, results, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

#Test building with invalid count
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :count => 'title')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete.ensure_correct_counts('a', nil, results, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1])

#Test building with incomplete count (some count contents empty)

# Enqueue new document without a count
words = [
  "alpha","bravo","charlie","delta","echo",
  "foxtrot","golf","hotel","india","juliet",
  "kilo","lima","mike","november","oscar",
  "papa","quebec","romeo","sierra","tango",
  "uniform","victor","whiskey","xray","yankee","zulu"
]

xml_doc = Nokogiri::XML::Document.new

doc_n = 11
text = ""
acl = ""

content = xml_doc.create_element('content')
content['name'] = 'title'
content['type'] = 'text'

10.times do |word_n|
  word = words[(doc_n * word_n) % words.size]
  text << "#{word} "
end
content.content = text.strip

3.times do |i|
  acl << "#{doc_n + i}\n"
end
content['acl'] = acl.strip

doc = xml_doc.create_element('document')
doc << content

content = xml_doc.create_element('content')
content['name'] = 'count'
content['type'] = 'text'

doc << content

cd = xml_doc.create_element('crawl-data')
cd['encoding'] = 'xml'
cd['content-type'] = 'application/vxml'
cd << doc

cu = xml_doc.create_element('crawl-url')
cu['url'] = "http://127.0.0.1/#{doc_n}"
cu['synchronization'] = 'indexed'
cu['status'] = 'complete'
cu << cd

input_collection.enqueue_xml(cu)

dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :security => 'none', :count => 'count')
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

autocomplete.ensure_correct_counts('l', nil, results, [3, 1, 1])

correct_suggestions = ['alpha bravo charlie delta echo foxtrot golf hotel india juliet', 'alpha hotel oscar victor charlie juliet quebec xray echo lima', 'alpha lima whiskey hotel sierra delta oscar zulu kilo victor']
autocomplete.ensure_correct_counts('h', nil, results, [9, 3, 1])
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

results.cleanup_and_exit!(true)
