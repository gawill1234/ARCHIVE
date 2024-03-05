#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new("Test that URLs containing sequences of spaces can be crawled.")

collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create('default')
collection.add_crawl_seed(:vse_crawler_seed_urls,
                 :urls => 'http://testbed14.test.vivisimo.com/bug-23456/')
collection.crawler_start
sleep 5
collection.wait_until_idle
# There should be six documents total
results.add_equals(6, collection.search_total_results, 'total results')

# Each document contains a unique word. Check each one.
['extractor', 'accommodate', 'diverse', 'nightmare', 'wishing',
 'ramifications'].each {|word|
  results.add_equals(1, collection.search_total_results(:query => word),
                     "'#{word}' results")}

results.cleanup_and_exit!
