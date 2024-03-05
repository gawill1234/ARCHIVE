#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/collection-broker'
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/read-only'

require 'misc'
require 'collection'
require 'config'
require 'read-only-files'

CRAWL_NODES = '<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="indexed-no-sync"
             url="http://vivisimo.com/dummy">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

results = TestResults.new("Test for bug 22934.",
                          "1) create collection",
                          "2) offline enqueue",
                          "3) enable read-only",
                          "4) query collection")

results.fail_severity = 'error-unknown'
bc = Broker_Config.new
bc.set('always-allow-one-collection' => 'false', 'maximum-collections' => '0')
msg bc

collection = Collection.new(File.basename($0)[0..-5])
results.associate(collection)
collection.delete
collection.create

results.add(collection.broker_enqueue_xml(CRAWL_NODES),
            "collection-broker-enqueue-xml")

ro_request = collection.read_only(:enable)
msg ro_request.inspect
results.add((not ro_request['acquired'].nil?),
            "'acquired' read-only immediately.",
            "read-only not 'acquired' immediately for offline collection.")

bc.set
begin
  collection.broker_search
rescue VapiException => ex
  EXPECTED_MESSAGE = "Could not start the collection because its database has not been created yet and it cannot perform this operation in read-only mode."
  msg "Expecting message: " + EXPECTED_MESSAGE
  results.add(ex.message.include?(EXPECTED_MESSAGE),"got expected error message")
end

sleep 1

now = iso8601
sr = collection.vapi.reports_system_reporting(:start => results.start_iso8601,
                                              :end => now,
                                              :max_items => 10000)

results.add((not sr.to_s[/FATAL_ERROR/]),
            "No FATAL_ERROR :-)",
            "FATAL_ERROR seen.")

results.cleanup_and_exit!
