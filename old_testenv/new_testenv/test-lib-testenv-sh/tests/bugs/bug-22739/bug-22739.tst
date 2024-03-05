#!/usr/bin/env ruby
# Test: bug-22739
#
# Test that invalid filenames do not cause crashes

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/dummy">
    <crawl-data content-type="application/vxml-unnormalized">
      <vxml>
        <document>
            <content name="bday">1950-11-12T00:00:00.000-05:00</content>
            <content name="bday2">-603918000</content>
        </document>
      </vxml>
    </crawl-data>
  </crawl-url>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/dummy2">
    <crawl-data content-type="application/vxml-unnormalized">
      <vxml>
        <document>
         <content name="bday">1978-11-12T00:00:00.000-05:00</content>
         <content name="bday2">279694800</content>
      </document>
    </vxml>
    </crawl-data>
  </crawl-url>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/dummy3">
    <crawl-data content-type="application/vxml-unnormalized">
      <vxml>
        <document>
         <content name="bday">1980-11-12T00:00:00.000-05:00</content>
         <content name="bday2">342853200</content>
      </document>
      </vxml>
    </crawl-data>
  </crawl-url>
</crawl-urls>'
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-22739",
                               "1.  Date search before and after 1950")

collection = Collection.new("bug-22739", velocity, user, password)
collection.delete()
collection.create()

# Crawl collection
collection.enqueue_xml(CRAWL_NODES)
# Query collection
query_results = vapi.query_search(:sources => "bug-22739",
                            :query => "")
sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

test_results.add(sum == 3,
                 "Null query.",
                 "Null query.  Expected 3, got" + sum.to_s)

query_results = vapi.query_search(:sources => "bug-22739",
                            :query_object => "<query-object><operator logic=\"xpath\">
                                    <term field=\"v.condition-xpath\" str=\"$year &lt; 1981\" /></operator></query-object>")

sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}

test_results.add(sum == 3,
                 "Query:  bday:<01/01/1981",
                 "Query:  bday:<01/01/1981. Expected 3, got" + sum.to_s)


query_results = vapi.query_search(:sources => "bug-22739",
                                  :query_object => "<query-object><operator logic=\"and\">
                                          <term field=\"v.condition-xpath\" str=\"$year &gt; 2010\" /></operator></query-object>")

sum = 0
query_results.xpath('/query-results/added-source/@total-results-with-duplicates').each {|node| sum += node.to_s.to_i}


test_results.add(sum == 0,
                 "Query:  bday:>01/01/2010",
                 "Query:  bday:>01/01/2010. Expected 0, got" + sum.to_s)

#Cleanup
msg "Cleanup"
collection.delete()

test_results.cleanup_and_exit!
