#!/usr/bin/env ruby
# Test: bug-27161
#
# Test that the correct exceptions are thrown
# when we fail to enqueue different crawl nodes
# to a collection.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'

#variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password

#All of the following nodes should produce the new exceptions
INVALID_ATTR = ["<crawl-url request-queue-redir=\"output\" />"]
INVALID_NODE = ["<crawl-foo />"]
INVALID_CRAWL_URL = [
                     "<crawl-url enqueue-type=\"none\" />",
                     "<crawl-url enqueue-type=\"forced\" />",
                     "<crawl-url enqueue-type=\"reenqueued\" />",
                     "<crawl-url enqueue-type=\"export\" />",
                     "<crawl-url />",
                     "<crawl-url status=\"starting\" />",
                     "<crawl-url status=\"applying changes\" />",
                     "<crawl-url status=\"stopping\" />",
                     "<crawl-url status=\"refreshing\" />",
                     "<crawl-url status=\"resuming\" />",
                     "<crawl-url status=\"input\" />",
                     "<crawl-url status=\"redir\" />",
                     "<crawl-url status=\"disallowed by robots.txt\" />",
                     "<crawl-url status=\"filtered\" />",
                     "<crawl-url status=\"error\" />",
                     "<crawl-url status=\"duplicate\" />",
                     "<crawl-url status=\"killed\" />",
                     "<crawl-url status=\"none\" />"
                    ]
INVALID_CRAWL_DELETE = [
                        "<crawl-delete />",
                        "<crawl-delete vse-key=\"foo\" recursive=\"true\" />",
                        "<crawl-delete url=\"fake://f.oo\" vertex=\"666\" />",
                        "<crawl-delete vse-key=\"foo\" url=\"fake://f.oo\" />",
                        "<crawl-delete vse-key=\"foo\" vertex=\"666\" />",
                        "<crawl-delete vse-key=\"foo\" url=\"fake://f.oo\""\
                        " vertex=\"666\" />"
                       ]
INVALID_CRAWL_STATE = [
                       "<crawl-state />",
                       "<crawl-state name=\"foo\" />"
                      ]
INVALID_INDEX_ATOMIC = [
                        "<index-atomic partial=\"partial\" />",
                        "<index-atomic delete=\"delete\" recursive=\"recursiv"\
                        "e\"><crawl-delete url=\"fake://f.oo\" recursive=\"re"\
                        "cursive\" /><crawl-delete url=\"fake://b.ar\" /><cra"\
                        "wl-delete url=\"fake://bar.foo\" /></index-atomic>"
                       ]

#These are the names of the exceptions we're checking for
INVALID_NODE_EXCEPTION = "search-collection-enqueue-invalid-node"
INVALID_ATTR_EXCEPTION = "search-collection-enqueue-invalid-attr"
CRAWL_URL_EXCEPTION = "search-collection-enqueue-malformed-crawl-url"
CRAWL_DELETE_EXCEPTION = "search-collection-enqueue-malformed-crawl-delete"
CRAWL_STATE_EXCEPTION = "search-collection-enqueue-malformed-crawl-state"
INDEX_ATOMIC_EXCEPTION = "search-collection-enqueue-malformed-index-atomic"

#A complex array of the errors and the expected exceptions
ERROR_IDX = 0
EXCEPTION_IDX = 1
ERRORS_AND_EXCEPTIONS = [
                         [INVALID_ATTR, INVALID_ATTR_EXCEPTION],
                         [INVALID_NODE, INVALID_NODE_EXCEPTION],
                         [INVALID_CRAWL_URL, CRAWL_URL_EXCEPTION],
                         [INVALID_CRAWL_DELETE, CRAWL_DELETE_EXCEPTION],
                         [INVALID_CRAWL_STATE, CRAWL_STATE_EXCEPTION],
                         [INVALID_INDEX_ATOMIC, INDEX_ATOMIC_EXCEPTION]
                        ]

vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-27161",
                               "Test that the correct exceptions are thrown"\
                               " when we fail to enqueue different crawl nodes"\
                               " to a collection.")
collection = Collection.new("bug-27161", velocity, user, password)
collection.delete
collection.create("default-push")

#Loop through the complex array and ensure that

ERRORS_AND_EXCEPTIONS.each { |error_exception|
  error_exception[ERROR_IDX].each { |error|
    begin
      collection.enqueue(error)
    rescue => e
      if (! e.to_s.include? error_exception[EXCEPTION_IDX])
        test_results. add_failure("Expected the \""\
                                  "#{error_exception[EXCEPTION_IDX]}\" "\
                                  "exception but \"#{e.to_s}\" was thrown "\
                                  "instead")
      end
    else
      test_results.add_failure("Attempting to enqueue \"#{error}\" should have"\
                               " raised a exception but it didn't")
    end
  }
}

collection.delete
test_results.cleanup_and_exit!
