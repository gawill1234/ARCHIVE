#!/usr/bin/env ruby

require "misc"
require "velocity/example_metadata"

results = TestResults.new('Search results include cached versions of the document')
results.need_system_report = false

collection = ExampleMetadata.new
results.associate(collection)

class QuerySearchCacheTest < Struct.new(:collection, :results)
  def before_all
    collection.ensure_correctness
  end

  def before_each
    doc = collection.search("Slow Leak", :output_cache_data => true).xpath('//document').first
    @cache = doc.xpath('cache').first
  end

  def it_exists
    results.add(@cache != nil, "the cache exists")
  end

  def it_has_text_from_the_document
    results.add_matches(/a forgotten incident in her past/, @cache.text, :what => 'cache text')
  end

  def it_retains_original_structure
    html = Nokogiri::HTML(@cache.text)

    results.add_number_equals(1, html.xpath('//head').count, 'HEAD tag')
    results.add_number_equals(1, html.xpath('//body').count, 'BODY tag')
  end
end

test = QuerySearchCacheTest.new(collection, results)

test.before_all
[:it_exists, :it_has_text_from_the_document, :it_retains_original_structure].each do |method|
  test.before_each
  test.send(method)
end

results.cleanup_and_exit!(true)
