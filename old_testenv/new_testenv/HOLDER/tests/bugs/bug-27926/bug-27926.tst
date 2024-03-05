#!/usr/bin/env ruby
# Test: bug-27926
#
# Test that we don't crash the indexer-service by printing
# to an inacessible file.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#Constants
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
is_win = TESTENV.windows

VSE_IDX_OP_LOGGING = "query-logging"
VSE_IDX_OP_LFILE = "query-log-file"
LOG_FILE_LINUX = "/mnt/query.log"
LOG_FILE_WINDOWS = "C:\\Windows\\query.log"
VSE_INDEX_XPATH = "//vse-index"

#Configuration
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-27926", "Test that the indexer-service "\
                               "does not crash if it is given an inaccessible "\
                               "query log file")
collection = Collection.new("bug-27926", velocity, user, password)

#Initiailization
collection.delete
collection.create("example-metadata")

xml_collection = Nokogiri::XML(collection.xml.to_s)

#Configure the query log options
idx_option_logging = Nokogiri::XML::Node.new("vse-index-option", xml_collection)
idx_option_logging["name"] = VSE_IDX_OP_LOGGING
idx_option_logging.content = "true"

idx_option_lfile = Nokogiri::XML::Node.new("vse-index-option", xml_collection)
idx_option_lfile["name"] = VSE_IDX_OP_LFILE
idx_option_lfile.content = is_win ? LOG_FILE_WINDOWS : LOG_FILE_LINUX

xml_collection.xpath(VSE_INDEX_XPATH).first << idx_option_logging << idx_option_lfile

#Update the  collection to enable query logging
collection.set_xml(xml_collection)


begin
  retval = collection.indexer_start
rescue
  test_results.add_failure("The indexer failed to start")
else
  test_results.add_success("The indexer properly handled the bad query log path")
end

#Cleanup
collection.delete
test_results.cleanup_and_exit!
