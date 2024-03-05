#!/usr/bin/env ruby
#
# Test: ontolection-english
#
# This test performs a default English Ontolection crawl followed by some simple
# query syntax tests. It should be pretty fast.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#Constants
testname         = TESTENV.test_name
QUERIES_RESULTS  = {"theater" => 1,
                    "africanamerican" => 1}
EXPECTED_N_DOCS  = 1538
XPATH_DOCLIST    = "//list/document"
#Test
##0. Initialize Test Framework
test_results = TestResults.new(testname,
                               "This test performs a default English Ontolecti"\
                               "on crawl followed by some simple query syntax "\
                               "tests. It should be pretty fast.")
collection = Collection.new(testname)
test_results.associate(collection)
collection.delete
collection.create("ontolection-english-spelling-variations")

##1. Start Collection Crawl
collection.crawler_start
collection.wait_until_idle

##2. Get Collection Size
test_results.add(collection.index_n_docs == EXPECTED_N_DOCS,
                 "The #{testname} index has #{EXPECTED_N_DOCS} as expected.",
                 "The #{testname} index has #{collection.index_n_docs}, but it"\
                 " should have #{EXPECTED_N_DOCS}.")

##3. Perform Queries and ensure we see the correct number of returned results
QUERIES_RESULTS.each do |query, nresult|
  ndocs = collection.search(query).xpath(XPATH_DOCLIST).size
  test_results.add(ndocs == nresult,
                 "Searching \"#{query}\" returned #{ndocs} results.",
                 "Searching \"#{query}\" returned #{ndocs} results, but it sho"\
                 "uld have returned #{nresult} many.")
end

#Cleanup
test_results.cleanup_and_exit!
