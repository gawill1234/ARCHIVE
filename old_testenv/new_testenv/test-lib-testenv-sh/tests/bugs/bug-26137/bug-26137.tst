#!/usr/bin/env ruby
#
#

require 'misc'
require 'collection'
require 'testenv'
require 'gronk'
require 'vapi'

# Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
vapi = Vapi.new(velocity, user, password)
dictionary_xml = '<dictionary name="bug-26137">
<dictionary-inputs>
<call-function name="dict-input-collection">
<with name="name">bug-26137</with>
<with name="contents">phrase</with>
<with name="security">none</with>
</call-function>
</dictionary-inputs>
<dictionary-outputs>
<call-function name="dict-output-spelling" />
<call-function name="dict-output-wildcard" />
<call-function name="dict-output-stemming">
<with name="stemmer">depluralize</with>
</call-function>
<call-function name="dict-output-stemming">
<with name="stemmer">english+depluralize</with>
</call-function>
</dictionary-outputs>
</dictionary>'

CRAWL_NODES = '      <crawl-urls>
        <crawl-url url="a" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">hello world</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="b" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">foo</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="c" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">try using CONTENT text CONTAINING</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="d" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="phrase" type="text">bar test add more words</content>
            </document>
          </crawl-data>
        </crawl-url>
      </crawl-urls>'
SEARCH_SERVICE_CONFIG =
    "<vse-qs>
       <vse-qs-option>
        </vse-qs-option>
      </vse-qs>"
SEARCH_SERVICE_CONFIG_RESET =
    "<vse-qs>
       <vse-qs-option>
          <port>7205</port>
        </vse-qs-option>
      </vse-qs>"
expected_count = 9
sum = 0

begin
  results = TestResults.new('Test bug 26137: Verifies that dictionary can be built when search-service port is set to nothing')

  # Create search collection
  msg "Creating search collection: bug-26137"
  collection = Collection.new("bug-26137", velocity, user, password)
  results.associate(collection)
  collection.delete()
  collection.create()

  # Enqueue data to collection
  vapi.search_collection_enqueue_xml(:collection => "bug-26137",
                                     :subcollection => "live",
                                     :crawl_nodes => CRAWL_NODES)

  # Clear search service port
  msg "Set search service port to nothing"
  vapi.search_service_set(:configuration => SEARCH_SERVICE_CONFIG)
  
  # Create dictionary
  msg "Creating dictionary: bug-26137"
  vapi.dictionary_delete(:dictionary => "bug-26137")
  vapi.dictionary_create(:dictionary => "bug-26137")
  vapi.repository_update(:node => dictionary_xml)
  vapi.dictionary_build(:dictionary => "bug-26137")

  # Make sure dictionary build completed
  msg "Checking status of dictionary build"
  dictionary_status_xml = vapi.dictionary_status_xml(:dictionary => "bug-26137")
  status = dictionary_status_xml.xpath('/dictionary/dictionary-status/@status').first.to_s
  complete_status = "finished"

  while status != complete_status do
     Kernel.sleep(2)
     dictionary_status_xml = vapi.dictionary_status_xml(:dictionary => "bug-26137")
     status = dictionary_status_xml.xpath('/dictionary/dictionary-status/@status').first.to_s
  end

  # Get word count in dictionary
  msg "Check dictionary word count"
  status_response_before = vapi.dictionary_status_xml(:dictionary => "bug-26137")
  status_response_before.xpath('/dictionary/dictionary-status/dictionary-status-item/@total').each {|node| sum += node.to_s.to_i}
  results.add(expected_count == sum, "Dictionary count matches expected value")

  # Reset search service config
  msg "Set search service port back to default"
  vapi.search_service_set(:configuration => SEARCH_SERVICE_CONFIG_RESET)

  results.cleanup_and_exit!
end
