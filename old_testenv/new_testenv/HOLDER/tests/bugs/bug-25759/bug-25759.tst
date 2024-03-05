#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

# Variables
test_results = TestResults.new("Test for bug 25759: Incorrect URL parsing")
collection   = Collection.new("bug-25759")
test_results.associate(collection)
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
vapi = Vapi.new(velocity, user, password)

# Test Cases
crawl_node_1 = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://@vivisimo.com/dummy1">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

crawl_node_2 = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://me@vivisimo.com/dummy2">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

crawl_node_3 = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://:vivisimo.com/dummy3">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

crawl_node_4 = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://me:@vivisimo.com/dummy4">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

crawl_node_5 = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://:mypass@vivisimo.com/dummy5">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

crawl_node_6 = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://me:mypass@vivisimo.com/dummy6">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

collection.delete
collection.create

# Cases
# No ':' character, with and without a username given,
# http://@foobar.com/
collection.enqueue_xml(crawl_node_1)
query_results1 = vapi.query_search(:sources => "bug-25759",
                            :query => "")
url1 = query_results1.xpath('/query-results/list/document/@url').to_s

test_results.add(url1 == "http://@vivisimo.com/dummy1",
          "Case: http://@foobar.com/",
          "Expected url not returned.")

# http://u@foobar.com/
collection.enqueue_xml(crawl_node_2)
query_results2 = vapi.query_search(:sources => "bug-25759",
                            :query => "dummy2")
url2 = query_results2.xpath('/query-results/list/document/@url').to_s

test_results.add(url2 == "http://me@vivisimo.com/dummy2",
          "Case: http://u@foobar.com/",
          "Expected url not returned")

# With a ':' character, with and without both a username and a password,
# http://:@foobar.com/
collection.enqueue_xml(crawl_node_3)
query_results3 = vapi.query_search(:sources => "bug-25759",
                            :query => "dummy3")
url3 = query_results3.xpath('/query-results/list/document/@url').to_s

test_results.add(url3 == "http://:vivisimo.com/dummy3",
          "Case: http://:@foobar.com/",
          "Expected url not returned")

# http://u:@foobar.com/
collection.enqueue_xml(crawl_node_4)
query_results4 = vapi.query_search(:sources => "bug-25759",
                            :query => "dummy4")
url4 = query_results4.xpath('/query-results/list/document/@url').to_s

test_results.add(url4 == "http://me:@vivisimo.com/dummy4",
          "Case: http://u:@foobar.com/",
          "Expected url not returned")

# http://:p@foobar.com/
collection.enqueue_xml(crawl_node_5)
query_results5 = vapi.query_search(:sources => "bug-25759",
                            :query => "dummy5")
url5 = query_results5.xpath('/query-results/list/document/@url').to_s

test_results.add(url5 == "http://:mypass@vivisimo.com/dummy5",
          "Case: http://:p@foobar.com/",
          "Expected url not returned")

# http://u:p@foobar.com/
collection.enqueue_xml(crawl_node_6)
query_results6 = vapi.query_search(:sources => "bug-25759",
                            :query => "dummy6")
url6 = query_results6.xpath('/query-results/list/document/@url').to_s

test_results.add(url6 == "http://me:mypass@vivisimo.com/dummy6",
          "Case: http://u:p@foobar.com/",
          "Expected url not returned")

test_results.cleanup_and_exit!
