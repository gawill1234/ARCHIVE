#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'

require 'misc'
require 'dictionary_collections'
require 'autocomplete_indexer_app'

results = TestResults.new('Test to see if the autocomplete indexer app will respect rights')
results.need_system_report = false

collection = DictionarySimple.new
results.associate(collection)
collection.setup

app = AutocompleteIndexerApp.new(collection.name)

def expect_no_exception(index_data, results)
  exceptions = index_data.xpath('//exception')
  results.add_number_equals(0, exceptions.size, 'exception')

  exceptions.each do |e|
    puts e
  end
end

def check_acls(documents, acls, results)
  documents.each_with_index do |doc, i|
    contents = doc.xpath('content')
    results.add_number_equals(1, contents.size, 'content element')

    content = contents.first

    results.add_equals('title', content['name'], 'content name')
    results.add_equals(acls[i], content['acl'], 'content acl')
  end
end

# Test with no rights set
index_data = app.get_data(['title'])
expect_no_exception(index_data, results)

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(10, documents.size, 'document element')

# Test with empy rights string
index_data = app.get_data(['title'], :acls => '')
expect_no_exception(index_data, results)

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(0, documents.size, 'document element')

# Test with single acl
index_data = app.get_data(['title'], :acls => '4')
expect_no_exception(index_data, results)

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(3, documents.size, 'document element')

acls = ["2\n3\n4",
        "3\n4\n5",
        "4\n5\n6"]

check_acls(documents, acls, results)

next_page = container.xpath('r')
results.add_number_equals(0, next_page.size, 'r element')

# Test with extra non-matching acl
index_data = app.get_data(['title'], :acls => "4\nzebra")
expect_no_exception(index_data, results)

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(3, documents.size, 'document element')

acls = ["2\n3\n4",
        "3\n4\n5",
        "4\n5\n6"]

check_acls(documents, acls, results)

next_page = container.xpath('r')
results.add_number_equals(0, next_page.size, 'r element')

# Test with extra multiple acls
index_data = app.get_data(['title'], :acls => "3\n4\n5")
expect_no_exception(index_data, results)

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(5, documents.size, 'document element')

acls = ["1\n2\n3",
        "2\n3\n4",
        "3\n4\n5",
        "4\n5\n6",
        "5\n6\n7"]

check_acls(documents, acls, results)

next_page = container.xpath('r')
results.add_number_equals(0, next_page.size, 'r element')

# Test with non-matching acl
index_data = app.get_data(['title'], :acls => 'zebra')
expect_no_exception(index_data, results)

container = index_data.xpath('/vce/results')
results.add_number_equals(1, container.size, 'result element')

documents = container.xpath('document')
results.add_number_equals(0, documents.size, 'document element')

results.cleanup_and_exit!(true)
