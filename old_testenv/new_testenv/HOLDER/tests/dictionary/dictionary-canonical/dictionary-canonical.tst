#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Basic test to see if dictionary autocomplete canonical form works')
results.need_system_report = false

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)

input_collection = DictionaryCanonical.new
results.associate(input_collection)
input_collection.setup

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)

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

msg("Test that canonical form is preserved when stemmer is set to 'none'")
dict.setup_and_build(results) do |dict|
  dict.set_stemmer('none')
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'contact')
end
results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')

correct_suggestions = ['Barack Obama']
autocomplete.ensure_correct_counts('Bar', nil, results, [1])
autocomplete.ensure_correct_suggestions('Bar', nil, results, correct_suggestions)

msg("Test that different cases are returned when stemmer is set to 'none'")
#Enqueue a new document that contains 'barack obama' (different letter case)
xml_doc = Nokogiri::XML::Document.new

content = xml_doc.create_element('content')
content['name'] = 'contact'
content.content = 'barack obama'

doc = xml_doc.create_element('document')
doc << content

cd = xml_doc.create_element('crawl-data')
cd['encoding'] = 'xml'
cd['content-type'] = 'application/vxml'
cd << doc

cu = xml_doc.create_element('crawl-url')
cu['url'] = "http://127.0.0.1/4"
cu['synchronization'] = 'indexed'
cu['status'] = 'complete'
cu << cd

input_collection.enqueue_xml(cu)

dict.setup_and_build(results) do |dict|
  dict.set_stemmer('none')
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'contact')
end

correct_suggestions = ['Barack Obama', 'barack obama']
autocomplete.ensure_correct_counts('Bar', nil, results, [1, 1])
autocomplete.ensure_correct_suggestions('Bar', nil, results, correct_suggestions)

msg("Test that symbols are preserved with canonical form")
dict.setup_and_build(results) do |dict|
  dict.set_stemmer('none')
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'email')
end

correct_suggestions = ['JOE@BLAH.COM', 'joe@blah.com']
autocomplete.ensure_correct_counts('joe@b', nil, results, [1, 1])
autocomplete.ensure_correct_suggestions('joe@b', nil, results, correct_suggestions)

msg("Test that symbols are preserved with canonical form even when stemming")
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(input_collection.name, :contents => 'email')
end

correct_suggestions = ['joe@blah.com']
autocomplete.ensure_correct_counts('joe@b', nil, results, [2])
autocomplete.ensure_correct_suggestions('joe@b', nil, results, correct_suggestions)

results.cleanup_and_exit!(true)
