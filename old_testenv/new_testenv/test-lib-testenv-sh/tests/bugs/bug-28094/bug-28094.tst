#!/usr/bin/env ruby
#
# Test: Bug 28094
#
# This test is designed to ensure that we do not cause a
# stack overflow using alloca() when we should be using
# malloc to transfer an xmlNode attribute.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'gronk'
require 'misc'
require 'net/http'
require 'nokogiri'
require 'velocity/source'

#Constants
velocity      = TESTENV.velocity
user          = TESTENV.user
password      = TESTENV.password
is_win        = TESTENV.windows
EXEC          = is_win ? ".exe" : "";
TESTNAME      = "bug-28094"
FAULTY_FILE   = "#{ENV['VIV_WEB_SERVER']}/bug_data/28094/request_body.25"
FAULTY_SOURCE = "<source name=\"#{TESTNAME}\" test-strictly=\"test-strictly\">"\
                "<submit><form><call-function name=\"standard-form\"><with nam"\
                "e=\"action-value\">#{FAULTY_FILE}</with></ca"\
                "ll-function></form></submit><tests /><help /><description /><"\
                "/source>"
VELOCITY      = "velocity" << EXEC
QUERY_META    = "query-meta" << EXEC
QUERY_ARGS    = "?v%3Asources=#{TESTNAME}&v%3Aproject=query-meta&query="

#Helper Function
def validate(http_resp)
  (http_resp =~ /Integrate the Pore size distribution data/) != nil
end

#Test
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new(TESTNAME,
                               "Test that we no longer encounter a s"\
                               "tack overflow in translate_descriptor "\
                               "that crashes query-meta.")

##0. Create Collection, Replace Source and Start Crawl
collection = Collection.new(TESTNAME, velocity, user, password)
test_results.associate(collection)
collection.delete
collection.create("example-metadata")

source = Velocity::Source.new(vapi, TESTNAME)
source.create(FAULTY_SOURCE)

collection.crawler_start
collection.wait_until_idle

##1. Set our Query URL and check for an HTTP 500 error
query_url = URI(velocity.to_s.chomp(VELOCITY) << QUERY_META << QUERY_ARGS)
response = Net::HTTP.get(query_url)
test_results.add(validate(response),
                 "Successfully generated the search page",
                 "Failed to generate the search page (Possibly encountered HTTP"\
                 " Error)\n*** Full response: ***\n#{response}\n*** End of full "\
                 "response ***")

##3. Cleanup
test_results.cleanup_and_exit!
