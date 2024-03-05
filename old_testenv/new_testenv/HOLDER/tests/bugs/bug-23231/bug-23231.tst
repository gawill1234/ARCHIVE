#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

# Variables
@test_results = TestResults.new("Test for bug 23231: Remove @delete-target crawl-delete code")
@collection   = Collection.new("bug-23231")
@test_results.associate(@collection)

crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE
crawl_delete = <<-HERE
  <crawl-urls synchronization="indexed">
    <crawl-delete url="http://vivisimo.com/dummy" delete-target="log"/>
  </crawl-urls>
HERE

velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
vapi = Vapi.new(velocity, user, password)

# Create collection
@collection.delete
@collection.create

# Enqueue content
@collection.enqueue_xml(crawl_nodes)

# Search to ensure content was indexed
query_results = vapi.query_search(:sources => "bug-23231",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

@test_results.add(sum == 1,
                 "Verify content was indexed",
                 "No Search results returned.  Expected 1, got" + sum.to_s)

# enqueue a crawl delete
@collection.enqueue_xml(crawl_delete)

query_results = vapi.query_search(:sources => "sc-dir",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

@test_results.add(sum == 0,
                 "Verify content was deleted",
                 "Search results returned.  Expected 0, got" + sum.to_s)

@test_results.cleanup_and_exit!
