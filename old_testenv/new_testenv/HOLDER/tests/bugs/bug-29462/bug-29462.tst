#!/usr/bin/env ruby

# This test was created to verify the fix for bug 29462.
# Before the fix, when a binning set was created with an
# arbitrary XPath and that XPath was mapped to a content,
# executing a query caused the indexer to crash. This test
# sets up binning sets with field mappings, executes
# queries, and verifies that the indexer does not crash
# and that the correct number of documents is returned. It
# tests mapping both an arbitrary field ("foo") and a field
# that is also a content ("hero").

require 'misc'
require 'velocity/example_metadata'
require 'velocity/source'

results = TestResults.new("Tests that using binning with field-mapping works as expected")

#Ensure that example-metadata is in the correct state
example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

#Create a collection based on example-metadata
collection = Collection.new('bug-29462')
results.associate(collection)
collection.delete
collection.create(example_metadata.name)

#Remove the existing binning sets
xml = collection.xml
xml.xpath("/vse-collection/vse-config/vse-index/binning-sets").remove unless xml.xpath("/vse-collection/vse-config/vse-index/binning-sets").empty?
collection.set_xml(xml)

#Add binning sets with XPaths $foo and $hero
collection.add_binning_set(Nokogiri::XML('<binning-set><call-function name="binning-set"><with name="select">$foo</with><with name="bs-id">foo</with></call-function></binning-set>'))
collection.add_binning_set(Nokogiri::XML('<binning-set><call-function name="binning-set"><with name="select">$hero</with><with name="bs-id">hero</with></call-function></binning-set>'))

#Add field mappings to map $foo to the content "hero" and $hero to the content "year"
source = Velocity::Source.new(example_metadata.vapi, 'bug-29462')
source.add_vse_form_with(Nokogiri::XML("<with name=\"fields\">hero|year\nfoo|hero</with>"))

#Start the crawler and indexer
collection.crawler_start
collection.wait_until_idle
results.add_equals('running', collection.indexer_service_status, "The indexer status")

#Execute a query. The indexer should not crash.
collection.search('')
results.add_equals('running', collection.indexer_service_status, "The indexer status")

#Check that the field-mapping actually works
msg('Checking how many documents are returned')

msg('Test bin with foo->hero mapping using a null query.')
total_results = collection.search_total_results('query' => '',
                           'binning-state' => "foo==Kit Fielding")
results.add_number_equals(2, total_results, 'document')

msg('Test bin with foo->hero mapping using a non-null query.')
total_results = collection.search_total_results('query' => 'jockey AND horse',
                           'binning-state' => "foo==Sid Halley")
results.add_number_equals(2, total_results, 'document')

msg('Test bin with hero->year mapping using a null query.')
total_results = collection.search_total_results('query' => '',
                           'binning-state' => "hero==1985")
results.add_number_equals(2, total_results, 'document')

msg('Test bin with hero->year mapping using a non-null query.')
total_results = collection.search_total_results('query' => 'jockey',
                           'binning-state' => "hero==1965")
results.add_number_equals(1, total_results, 'document')

msg('Test both bins using a null query.')
total_results = collection.search_total_results('query' => '',
                           'binning-state' => "hero==1985\nfoo==Kit Fielding")
results.add_number_equals(1, total_results, 'document')

msg('Test both bins using a non-null query.')
total_results = collection.search_total_results('query' => 'title:"ODDS AGAINST"',
                           'binning-state' => "foo==Sid Halley\nhero==1965")
results.add_number_equals(1, total_results, 'document')

#Cleanup
results.cleanup_and_exit!
