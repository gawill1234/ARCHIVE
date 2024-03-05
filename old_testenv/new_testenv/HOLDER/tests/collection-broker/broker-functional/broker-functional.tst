#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker/'

require 'config'
require 'misc'

# No longer looking for this exception
NO_SUCH_COLLECTION = '//exception[@name="search-collection-invalid-name"]'

COLLECTION_DOES_NOT_EXIST =
  '//error[@id = "COLLECTION_BROKER_COLLECTION_DOES_NOT_EXIST"]'
FOUND_NEW_COLLECTION = '//msg[@id="COLLECTION_BROKER_FOUND_NEW_COLLECTION"]'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/broker-functional">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here
    </crawl-data>
  </crawl-url>
</crawl-urls>'

def check_nonexistant(body, descrip)
  # This returns a array intended to be used as an argument list to results.add.
  # The first array element is step passed? with a value of true or false.
  # The second array element is the descriptive text for the success or failure.
  xml = Nokogiri::XML(body)
  # Top level return needs to be an exception
  if xml and xml.root and xml.root.name == 'exception'
    # Somewhere there needs to be an error saying the collection doesn't exist.
    if xml.xpath(COLLECTION_DOES_NOT_EXIST).empty?
      [false, "Fail: unexpected exception from #{descrip}: #{body}"]
    else
      if not xml.xpath(FOUND_NEW_COLLECTION).empty?
        [false, "Fail: (found '#{FOUND_NEW_COLLECTION}'): #{body}"]
      else
        [true, "Pass (found '#{COLLECTION_DOES_NOT_EXIST}')"]
      end
    end
  else
    [false, "Fail: unknown failure from #{descrip}: #{body}"]
  end
end

def enqueue_to_nonexistant(vapi)
  msg 'Enqueue to nonexistant collection'
  begin
    resp = vapi.collection_broker_enqueue_xml(
                :collection => 'no_such_collection_enqueue',
                :crawl_nodes => CRAWL_NODES,
                :v__indent => true)
    [false, "Fail: no exception returned by enqueue: #{resp}"]
  rescue VapiException => ex
    check_nonexistant(ex.message, 'enqueue')
  end
end

def search_nonexistant(vapi)
  msg 'Search a nonexistant collection'
  begin
    resp = vapi.collection_broker_search(
                :collection => 'no_such_collection_search',
                :v__indent => true)
    [false, "Fail: no exception returned by search: #{resp}"]
  rescue VapiException => ex
    check_nonexistant(ex.message, 'search')
  end
end

def start_nonexistant(vapi)
  msg 'Start a nonexistant collection'
  begin
    resp = vapi.collection_broker_start_collection(
                :collection => 'no_such_collection_start',
                :v__indent => true)
    [false, "Fail: no exception returned by 'start': #{resp}"]
  rescue VapiException => ex
    check_nonexistant(ex.message, 'start')
  end
end

results = TestResults.new('Test collection broker calls targeting',
                          'non-existent collections.')

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
bc = Broker_Config.new
bc.set
msg "Collection broker config: #{bc}"
results.add(*enqueue_to_nonexistant(vapi))
results.add(*search_nonexistant(vapi))
results.add(*start_nonexistant(vapi))
bc.set('always-allow-one-collection' => false,
       'maximum-collections' => 0)
msg "Collection broker config: #{bc}"
results.add(*enqueue_to_nonexistant(vapi))
results.add(*search_nonexistant(vapi))
results.add(*start_nonexistant(vapi))
bc.set('always-allow-one-collection' => false,
       'maximum-collections' => 0,
       'prefer' => 'enqueue')
msg "Collection broker config: #{bc}"
results.add(*enqueue_to_nonexistant(vapi))
results.add(*search_nonexistant(vapi))
results.add(*start_nonexistant(vapi))

results.cleanup_and_exit!
