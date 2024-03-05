#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'

results = TestResults.new('Basic test of dictionary rights combinations')
results.need_system_report = false

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

autocomplete = Autocomplete.new(TESTENV.test_name)

input_document_rights = Array.new
expected_results = Array.new

input_document_rights << ['1:a', '1:a']
expected_results <<      {'1:a' => 1}

input_document_rights << ['2:a', '-2:a']
expected_results <<      {'2:a' => 0}

input_document_rights << ['3:a', '3:b']
expected_results <<      {'3:a' => 1, '3:b' => 1}

input_document_rights << ['4:a', '-4:b']
expected_results <<      {'4:a' => 1, '4:b' => 0}

input_document_rights << ['5:a', '']
expected_results <<      {'5:a' => 1}

input_document_rights << ['6:a', nil]
expected_results <<      {'6:a' => 1}

input_document_rights << ['', ''] # This document will not create a suggestion
expected_results <<      {'' => 0}

input_document_rights << [nil, '']
expected_results <<      {'' => 0}
expected_results <<      {nil => 8} # no rights means all documents

input_document_rights << [nil, nil]
expected_results <<      {nil => 8} # no rights means all documents

def setup_collection_with_interesting_rights(input_document_rights)
  xdoc = Nokogiri::XML::Document.new

  cus = xdoc.create_element('crawl-urls')

  input_document_rights.each_with_index do |rights_set, test_i|
    cu = xdoc.create_element('crawl-url')
    cus << cu
    cu['url'] = test_i.to_s
    cu['synchronization'] = 'indexed-no-sync'
    cu['status'] = 'complete'

    cd = xdoc.create_element('crawl-data')
    cu << cd
    cd['encoding'] = 'xml'
    cd['content-type'] = 'application/vxml'

    doc = xdoc.create_element('document')
    cd << doc

    rights_set.each do |rights|
      content = xdoc.create_element('content')
      doc << content
      content['name'] = 'title'
      content['acl'] = rights if rights
      content.content = "Test phrase #{test_i}"
    end
  end

  collection = Collection.new(TESTENV.test_name)
  collection.delete
  collection.create('default-push')
  collection.set_index_options(:output_acls => true)

  collection.enqueue_xml(cus)

  return collection
end

class AutocompleteDictionary
  def setup_and_build(results)
    remove_all_inputs

    yield self

    build
    wait_until_finished(results)
  end
end

source_collection = setup_collection_with_interesting_rights(input_document_rights)
results.associate(source_collection)

# Test pushing to ac collection
dict.setup_and_build(results) do |dict|
  dict.add_autocomplete_collection_input(source_collection.name, :contents => 'title', :security => 'full')
end

msg "test for count without rights"
autocomplete.ensure_correct_counts('test', nil, results, [2, 2, 2, 2, 2, 2, 1, 1])
msg "test for count with rights"
autocomplete.ensure_correct_counts('test', {:rights => '1:a'}, results, [2])

msg "test that input rights combine correctly"
expected_results.each do |expected_set|
  expected_set.each do |rights, expected_count|
    res = autocomplete.suggestions('test', :rights => rights)
    suggestions = res.xpath('//suggestion')
    msg "rights: [#{rights}]" if rights
    results.add_number_equals(expected_count, suggestions.size, 'suggestion')
  end
end

results.cleanup_and_exit!(true)
