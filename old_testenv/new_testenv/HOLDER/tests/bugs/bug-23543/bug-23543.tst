#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new("Test .#name and ..#name in Samba crawls.")

collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create('default')
collection.add_crawl_seed(:vse_crawler_seed_smb,
                          :host => 'testbed5.test.vivisimo.com',
                          :username => 'gaw',
                          :password => '{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==',
                          :shares => '/testfiles/samba_test_data/bug-23543')
collection.crawler_start
sleep 5
collection.wait_until_idle
# There should be nine documents total
results.add_equals(9, collection.search_total_results, 'total results')

# Each document contains a unique word. Check each one.
['queuing', 'antonia', 'woodville', 'baptized', 'dismissively',
 'thatched', 'ascertained', 'congregational', 'calvin'].each {|word|
  results.add_equals(1, collection.search_total_results(:query => word),
                     "'#{word}' results")}

results.cleanup_and_exit!
