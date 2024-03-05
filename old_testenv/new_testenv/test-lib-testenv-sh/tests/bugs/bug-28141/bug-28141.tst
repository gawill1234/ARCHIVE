#!/usr/bin/env ruby
# Test: bug-28141
#
# Test that the number of documents in the index
# matches the expected value

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#variables
velocity        = TESTENV.velocity
user            = TESTENV.user
password        = TESTENV.password
COLLECTION_NAME = "bug-28141"
STATUS_XPATH    = "//vse-index-status"
LIST_XPATH      = "//vse-collection[@name='#{COLLECTION_NAME}']"
STATUS_ATTR     = "n-docs"
LIST_ATTR       = "live-done"


#0. Init Velocity API Connection
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new(COLLECTION_NAME,
                               "Test that the number of documents indexed is c"\
                               "orrectly reported by search-collection-list-xm"\
                               "l.")
collection = Collection.new(COLLECTION_NAME, velocity, user, password)
collection.delete
collection.create("example-metadata")

collection.crawler_start
collection.indexer_start

sleep(5)
status_xml = Nokogiri::XML(collection.status.to_s)
status_n_docs = status_xml.xpath(STATUS_XPATH).first.attr(STATUS_ATTR)

list_xml = Nokogiri::XML(vapi.search_collection_list_xml.to_s)
list_n_docs = list_xml.xpath(LIST_XPATH).first.attr(LIST_ATTR)

test_results.add((status_n_docs == list_n_docs), "search-collection-list-xml c"\
                 "orrectly reported the number of indexed documents", "The num"\
                 "ber of reported documents is wrong. Expected "\
                 "#{status_n_docs} but saw #{list_n_docs}.")

collection.delete
test_results.cleanup_and_exit!
