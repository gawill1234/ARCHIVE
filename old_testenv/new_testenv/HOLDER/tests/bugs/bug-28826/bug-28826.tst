#!/usr/bin/env ruby
# Test: bug-28826
#
# Test that the stopwords-query-english and stopwords-query-spanish
# macros do not strip user set attributes from a query.

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'collection'
require 'misc'
require 'nokogiri'

#Environment Variables
velocity = TESTENV.velocity
user = TESTENV.user
password = TESTENV.password

#Constants
NUM_ATTRS = [0, 10, 100]
QUERY = "The assassin as an all-embracing animosity of also an "
QUERY << "aardvark. Los lobos de la luna con leche."
QUERY_WORD = "Velocity"
N_TERMS = 8
MACROS = "stopwords-query-english stopwords-query-spanish"
QUERY_XPATH = "//query-results/query"

#Helper Functions
def generate_query_obj(query, num_attrs)
  term = ""
  term.chomp

  term << "<term field='query' str='#{query}' "
  num_attrs.times do |i| term << "attr#{i}='#{i}' " end

  term << "/>"
end

def attrs_preserved(q_term, n_attrs)
  i = 0
  q_term.each do |attr|
    if (attr[0][0,4] === "attr")
      i += 1
    end
  end
  i == n_attrs
end

#Initialization
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-28826",
                               "Test that stopwords macros return"\
                               " all user defined query-term attr"\
                               "ibutes")

collection = Collection.new("bug-28826", velocity, user, password)
collection.delete
collection.create("example-metadata")

collection.crawler_start
collection.indexer_start

#The Tests
macros_work = true;
attrs_saved = true;
NUM_ATTRS.each do |n_attrs|
  query_object = generate_query_obj(QUERY_WORD, n_attrs)
  ret_xml = Nokogiri::XML(collection.search(QUERY,
                                        {"query-object" => query_object,
                                          "query-modification-macros" => MACROS}
                                        ).to_s
                      )
  query_xml = (ret_xml.xpath("//query-results/query/operator").last)
  term_xml = query_xml.element_children
  if ((not term_xml.length == N_TERMS) or macros_work == false)
    test_results.add_failure("The macro returned #{term_xml.length} "\
                             " terms not the expected #{N_TERMS}")
    macros_work = false
  end

  if ((not attrs_preserved(term_xml.last, n_attrs)) or attrs_saved == false)
    test_results.add_failure("Some of the #{n_attrs} additional attributes"\
                             " were dropped from the terms")
    attrs_saved = false
  end
end

#Test Results
test_results.add(macros_work, "The macros still remove stopwords properly")
test_results.add(attrs_saved, "Attributes were not stripped by macros")

#Cleanup
collection.delete
test_results.cleanup_and_exit!
