#!/usr/bin/env ruby
#-------------------------
# (C) IBM Corporation 2012
#     All Rights Reserved
#-------------------------
# Test: bug-28634
#
# Test that various "meta" query option in the query-search api
# function do not improperly bold items in the search results.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#Constants
velocity     = TESTENV.velocity
user         = TESTENV.user
password     = TESTENV.password
ENQUEUE_DOCS = <<-HERE
<crawl-urls>
  <crawl-url url="fake://foo.bar" status="complete" synchronization="indexed" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml" encoding="xml">
      <document>
        <content name="title">foo bar 0 1</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://foo.baz" status="complete" synchronization="indexed" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml" encoding="xml">
      <document>
        <content name="title">foo baz 1 2</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
HERE

#Test
#0. Create a default-push collection and enqueue our documents
test_results = TestResults.new("Bug 28634", "Test that various 'meta' query op"\
                               "tions in the query-search api function do not "\
                               "improperly bold items in the search results")

vapi = Vapi.new(velocity, user, password)

collection = Collection.new("bug-28634", velocity, user, password)
test_results.associate(collection)

collection.delete
collection.create("default")
collection.set_crawl_options({}, {:default_allow => "allow"})

test_results.add(collection.enqueue_xml(ENQUEUE_DOCS),
                 "Successfully enqueued test documents",
                 "Failed to enqueue test documents")

#1. Perform a query-search call with a variety of non-default settings to try
#   and trigger a bad bold.
result =  collection.search(nil, {:start => 1,
                                  :output_bold_contents => "title",
                                  :sort_num_passages => 1,
                                  :rank_decay => 1,
                                  :num => 1,
                                  :num_over_request => 1,
                                  :num_per_source => 1,
                                  :num_max => 1,
                                  :browse => true,
                                  :browse_num => 1,
                                  :browse_clusters_num => 1,
                                  :term_expand_max_expansions => 1,
                                  :dict_expand_max_expansions => 1,
                                  :dict_expand_wildcard_enabled => true,
                                  :dict_expand_wildcard_min_length => 1,
                                  :collapse_num => 1,
                                  :aggregate_max_passes => 1,
                                  :cluster_near_duplicates => 1,
                                  :efficient_paging_n_top_docs_to_cluster => 1,
                                 }
                           )
#2. Check the result xml for <b> tags.
success = result.to_s =~ /\&lt\;b\&gt\;/ ? false : true


test_results.add(success,
                 "Nothing was bolded that shouldn't be!",
                 "Invalid <b> detected in query-result:\n #{result}")

test_results.cleanup_and_exit!
