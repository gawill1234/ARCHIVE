#!/usr/bin/env ruby

# Bug 2134: Do a search for a relational field that doesn't
#    exist should not throw an error.


$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'

COLLECTION = "bug-23134"

CRAWL_NODES = '<crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="foo://1">
    <crawl-data content-type="application/vxml" encoding="xml">
      <document><content name="title" fast-index="int">10</content></document>
    </crawl-data>
  </crawl-url>'

def enqueue(vapi)
  # This returns a array intended to be used as an argument list to results.add.
  # The first array element is step passed? with a value of true or false.
  # The second array element is the descriptive text for the success or failure.

  msg "Enqueue the data"
  resp = vapi.search_collection_enqueue(:collection => COLLECTION, :crawl_urls => CRAWL_NODES)
  if not resp or not resp.root
    [false, "Fail: missing root element in enqueue response"]
  elsif resp.root.name != 'crawler-service-enqueue-response'
    [false, "Fail: invalid enqueue response: #{resp.root.name}"]
  elsif resp.root['error']
    [false, "Fail: error in enqueue response: #{resp.root['error']}"]
  elsif resp.root['n-success'] != '1'
    [false, "Fail: invalid number of successes: #{resp.root['n-success']}"]
  else
    [true, "Pass: data enqueued"]
  end
end
  
def search_good(vapi, query)
  msg "Searching for #{query}, expect a result"
    xml = vapi.query_search(
                :sources => COLLECTION,
                :query => query
	   )
    if not xml or not xml.root
      [false, "Fail: missing root element" ]
    elsif xml.root.name != 'query-results'
      [false, "Fail: incorrect root element #{xml.root.name}" ]
    elsif xml.xpath('//document').empty?
      [false, "Fail: no document returned for the search: #{xml}"]
    else
      [true, "Pass: found a document"]
    end
end

results = TestResults.new('Check that using an invalid field in a relational query does not error')

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
vapi.search_collection_delete(:collection => COLLECTION, :kill_services => true, :force => true)
vapi.search_collection_create(:collection => COLLECTION)
results.add(*enqueue(vapi))
results.add(*search_good(vapi, 'title:==10'))
results.add(*search_good(vapi, 'title:==10 OR url:==10'))
vapi.search_collection_delete(:collection => COLLECTION, :kill_services => true, :force => true)
results.cleanup_and_exit!
