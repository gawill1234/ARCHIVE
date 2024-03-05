#!/usr/bin/env ruby                                                                                                                                                                                                               
# Test: bug-28498
#
# Test that inactive fast index fields do not
# load their value data into memory.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password
FAST_INDEX_FIELD = "hero"
FAST_INDEX_MODIFIED_ENTRIES = "year|int\ndatesecs|int"
FAST_INDEX_ORIGINAL_ENTRIES = "year|int hero datesecs|int"
FAST_INDEX_XPATH = "//vse-index-option['fast-index']"
MEMORY_NODE_XPATH = "//reconstructor-statuses/value-set-field[@name='hero']"
MEMORY_ATTR_NAME = "meta-bytes"
FAST_INDEX_STATE = "state"
DEAD_STATE = "dead"
ALIVE_STATE = "alive"

vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-28498",
                               "Test that inactive fast-index fields do not lo"\
                               "ad their data into memory")
collection = Collection.new("bug-28498", velocity, user, password)
collection.delete
collection.create("example-metadata")

collection.crawler_start
collection.indexer_start

xml_status = Nokogiri::XML(collection.status.to_s)
xml_memory = xml_status.xpath(MEMORY_NODE_XPATH).first
memory_prior = xml_memory.attr(MEMORY_ATTR_NAME)

xml_setup = Nokogiri::XML(collection.xml.to_s)

fi_fields = xml_setup.xpath(FAST_INDEX_XPATH).first
fi_fields.content = FAST_INDEX_MODIFIED_ENTRIES

collection.set_xml(xml_setup)
sleep(5)
collection.indexer_restart
sleep(5)

xml_status = Nokogiri::XML(collection.status.to_s)
xml_memory_after = xml_status.xpath(MEMORY_NODE_XPATH).first
memory_after = xml_memory_after.attr(MEMORY_ATTR_NAME)

success = (memory_after === '0') and (not memory_prior === '0')
success = success and (xml_memory.attr(FAST_INDEX_STATE) === DEAD_STATE)

test_results.add(success, "Successfuly prevented a dead fast index"\
                          " field from loading data into memory",
	"The dead fast index field loaded #{memory_after} bytes "\
        "out of the original #{memory_prior} into memory")

collection.delete
test_results.cleanup_and_exit!