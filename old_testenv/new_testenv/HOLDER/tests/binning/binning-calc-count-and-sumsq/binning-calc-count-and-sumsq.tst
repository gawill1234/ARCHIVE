#!/usr/bin/env ruby

#
# Test: binning-calc-count-and-sumsq
#
# This test verifies binning calculations for two new (as of 8.2-3)
# operators, count and sumsq (sum of squares)

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'

FIELD_NAME = "numericvalue"
COUNT_LABEL = "MyCount"
SUMSQ_LABEL = "MySumsq"

# ----------- Test Data -------------------
TEST_DATA_HEADER =
  "<crawl-urls>\n"\
  "  <curl-options>\n"\
  "    <curl-option name=\"default-allow\" added=\"added\">allow</curl-option>\n"\
  "    <curl-option name=\"max-hops\" added=\"added\">1</curl-option>\n"\
  "  </curl-options>\n"\
  "  <crawl-url url=\"http://vivisimo.com\" enqueue-type=\"forced\" status=\"complete\">\n"\
  "    <crawl-data content-type=\"application/vxml-unnormalized\" encoding=\"xml\">\n"\
  "      <vce>\n"

TEST_DATA_TEMPLATE =
  "        <document url=\"%s\">\n"\
  "          <content name=\"location\">%s</content>\n"\
  "          <content name=\"#{FIELD_NAME}\">%s</content>\n"\
  "        </document>\n"

TEST_DATA_TEMPLATE_NO_VALUE =
  "        <document url=\"%s\">\n"\
  "          <content name=\"location\">%s</content>\n"\
  "        </document>\n"


TEST_DATA_FOOTER =
  "        </vce>\n"\
  "      </crawl-data>\n"\
  "  </crawl-url>\n"\
  "</crawl-urls>\n"

def create_test_data(sets)
  test_data = TEST_DATA_HEADER
  sets.each do |url, location, value|
    if value.empty?
      test_data += TEST_DATA_TEMPLATE_NO_VALUE % [url, location]
    else
      test_data += TEST_DATA_TEMPLATE % [url, location, value]
    end
  end
  test_data += TEST_DATA_FOOTER
end

# ----------- Binning Configuration --------

BINNING_HEADER =
  "  <binning-sets>\n"\
  "    <binning-set>\n"\
  "    <call-function name=\"binning-set\">\n"\
  "      <with name=\"select\">$#{FIELD_NAME}</with>\n"\
  "      <with name=\"label\">#{FIELD_NAME}</with>\n"\
  "      <with name=\"bs-id\">#{FIELD_NAME}</with>\n"\
  "      <with name=\"disable-bin-pruning\">disable-bin-pruning</with>\n"\
  "    </call-function>\n"

BINNING_TEMPLATE =
  "   <binning-calculation>\n"\
  "      <call-function name=\"binning-calculation\">\n"\
  "        <with name=\"label\">%s</with>\n"\
  "        <with name=\"type\">%s</with>\n"\
  "      </call-function>\n"\
  "   </binning-calculation>"

BINNING_FOOTER =
  "  </binning-set>\n"\
  "</binning-sets>"

def create_binning_configuration(binning_calculations)
  binning_configuration = BINNING_HEADER
  binning_calculations.each do |calc_label, calc_type|
    binning_configuration += BINNING_TEMPLATE % [calc_label, calc_type]
  end
  binning_configuration += BINNING_FOOTER
end

FAST_INDEX =
  "<vse-index-option name=\"fast-index\">\n"\
  "#{FIELD_NAME}\n"\
  "</vse-index-option>\n"

# ---------- Search and verification -----

def verify_count_and_sumsq(results, collection, query, expected_count,
  expected_sumsq)
  qr = collection.vapi.query_search(:sources => collection.name,
    :query => query)
  count_value = qr.
    xpath("/query-results/binning/binning-set/binning-calculation"\
     "[@label='#{COUNT_LABEL}']/@value").to_s
  results.add(count_value == expected_count,
    "Found expected count",
    "Count returns #{count_value}, expected #{expected_count}")
  sumsq_value = qr.
    xpath("/query-results/binning/binning-set/binning-calculation"\
     "[@label='#{SUMSQ_LABEL}']/@value").to_s
  results.add(sumsq_value == expected_sumsq,
    "Found expected sumsq",
    "Sumsq returns #{sumsq_value}, expected #{expected_sumsq}")
end

def run_test(test_results, collection, description, query,
             expected_count, expected_sumsq)
  msg "#{description}:"
  verify_count_and_sumsq(test_results, collection, query,
    expected_count, expected_sumsq)
end

# ----------- Test Infrastructure ----------

test_results = TestResults.new("binning-calc-8",
  "This test verifies binning calculations for two new (as of 8.2-3) "\
  "operators, count and sumsq (sum of squares)")

test_results.need_system_report = false

# ----------- Collection ------------------
collection = Collection.new("binning-calc-8", TESTENV.velocity,
  TESTENV.user, TESTENV.password)
test_results.associate(collection)
collection.delete
collection.create("default")

TEST_SET = [
  ["no_values_in_given_field", "US > AL > Montgomery", ""],
  ["numeric_value_1", "US > AK > Juneau", "3"],
  ["too_big_numeric_value", "USA > AK > Anchorage", "2e+400"],
  ["too_small_numeric_value", "USA > AZ > Phoenix", "3e-400"],
  ["numeric_value_2", "US > AZ > Grand Canyon", "5"],
  ["numeric_value_3", "US > AZ > Sedona", "1"],
  ["almost_too_big_value_1", "USA > AR > Little Rock", "1e+154"],
  ["almost_too_big_value_2", "USA > AR > Territory", "1e+154"],
  ["big_negative_number", "USA > CA > Sacramento", "-2e+400"],
  ["non_numeric", "USA > CA > Los Angeles", "string"]
]
BINNING_CALC = [ ["#{COUNT_LABEL}", "count"], ["#{SUMSQ_LABEL}","sumsq"] ]
CURL_OPTIONS = [ ["default-allow", "allow"], ["max-hops", "1"] ]

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler/call-function").first.
  add_previous_sibling(create_test_data(TEST_SET))
place_for_index_conf =
  xml.xpath("/vse-collection/vse-config/vse-index/vse-index-streams").first
place_for_index_conf.
  add_next_sibling(create_binning_configuration(BINNING_CALC))
place_for_index_conf.add_previous_sibling(FAST_INDEX)
collection.set_xml(xml)
collection.set_crawl_options(crawl_option=[], curl_options=CURL_OPTIONS)
collection.crawler_start
collection.wait_until_idle

# ---------- Queries ---------------------

run_test(test_results, collection,
  "When a query returns no values for the given XPath expression, "\
  "count and sumsq both return zero.",
  "Montgomery", "0", "0")
run_test(test_results, collection,
  "On one numeric value", "Juneau", "1", "9")
run_test(test_results, collection,
  "On too-big numeric value", "Anchorage", "1", "INF")
run_test(test_results, collection,
  "When too-big value is one of values", "AK", "2", "INF")
run_test(test_results, collection,
  "On too-small numeric value", "Phoenix", "1", "0")
run_test(test_results, collection,
  "When to-small value is one of values", "AZ", "3", "26")
run_test(test_results, collection,
  "Adding two almost too big values", "AR", "2", "INF")
run_test(test_results, collection,
  "Checking that one of them is not too big on this machine",
     "Territory", "1", "1e+308")
run_test(test_results, collection,
  "On big negative number", "Sacramento", "1", "INF")
run_test(test_results, collection,
  "On non-numeric value", "Los Angeles", "1", "NaN")
run_test(test_results, collection,
  "With non-numeric value", "CA", "2", "NaN")
run_test(test_results, collection,
  "All non-special values", "US", "3", "35")
run_test(test_results, collection,
  "Empty query", "", "9", "NaN")
