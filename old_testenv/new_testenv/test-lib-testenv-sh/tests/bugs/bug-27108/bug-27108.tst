#!/usr/bin/env ruby
#
# Test: bug-27108
#
# This test should ensure that modifications made to the
# general-ontolection converter do what they were intended
# to do.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'gronk'
require 'misc'
require 'nokogiri'

#Constants
velocity    = TESTENV.velocity
user        = TESTENV.user
password    = TESTENV.password
platform    = ENV['VIVTARGETOS']
FILENAME    = "test-ontolection.xml"
CONV_XPATH  = "//call-function[@name='vse-converter-ontolection']"
SEED_XPATH  = "//crawler"
ARGS_XML    = "<with name=\"xpath-to-entry\">/terms/entity</with>"\
              "<with name=\"xpath-to-label\">name|@name</with>"\
              "<with name=\"xpath-to-synonyms\">synonym|same</with>"\
              "<with name=\"xpath-to-related\">related</with>"
DOCS_XPATH  = "//document"
TERMS_XPATH = "content[@name='term']"
SYNS_XPATH  = "content[@name='synonym']"
RELS_XPATH  = "content[@name='related']"


#Helper Functions
def validate_content(my_xpath, observed, expected, results, type)
  success = true
  items = observed.xpath(my_xpath)

  #Only Received Expected Docs?
  items.each do |item|
    if expected.include?(item.content)
      expected.delete_at(expected.index(item.content))
    else
      success = false
      results.add_failure("Encountered an unexpected document"\
                          " #{type}: #{item.content}.")
    end
  end

  #Didn't miss any expected docs?
  if expected.size != 0
    success = false
    expected.each do |missing_item|
      results.add_failure("Did not find expected #{type} \""\
                          "#{missing_item}\" in the returned docs.")
    end
  end
  
  results.add(success, "Successfully identified all the expected"\
              " '#{type}s' in the returned documents.",
              "The converter failed to properly parse the #{type}"\
              "s.")
end

def validate_docs(docs, results)
  #Expected values in the returned data
  expected_docs = ["Dream Theater", "Nightmare Cinema", "Daydream Matinee",
                   "Strapping Young Lad", "Opeth", "My Dying Bride",
                   "Meshuggah"]

  expected_syns = ["Dream Theater", "Nightmare Cinema", "Daydream Matinee",
		   "Dream Theater", "Opeth", "My Dying Bride"]

  expected_rels = ["Meshuggah"]

  #Correct number of docs?
  results.add(docs.size == expected_docs.size,
              "The converter created the expected number of documents.",
              "Expected #{expected_docs.size} documents in the collec"\
              "tion, but there are #{docs.size}.")

  #Validate document contents
  validate_content(TERMS_XPATH, docs, expected_docs, results, "term")
  validate_content(SYNS_XPATH, docs, expected_syns, results, "synonym")
  validate_content(RELS_XPATH, docs, expected_rels, results, "related term")

end

#Test
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new("bug-27108",
                               "Test that the updated ontolection converter wo"\
                               "rks as intended.")

##0. Initialize Gronk and its related variables, then send our test file
gronk = Gronk.new
install_dir = gronk.installed_dir

if platform == "windows"
  crawl_dir = install_dir.gsub("\\","\\\\\\").gsub(" ", "\\\ ") << "\\\\tmp"
  seed_crawl_dir = install_dir.gsub("\\","/") << "/tmp"
else
  crawl_dir = seed_crawl_dir = install_dir
end

`put_file -F #{FILENAME} -D #{crawl_dir}`

##1. Create Collection, update config, start crawl
collection = Collection.new("bug-27108", velocity, user, password)
test_results.associate(collection)
collection.delete
collection.create("generic-ontolection")

SEED_XML = "<call-function name=\"vse-crawler-seed-files\" type=\"crawl"\
           "-seed\"><with name=\"files\">#{seed_crawl_dir}/#{FILENAME}<"\
           "/with></call-function>"


xml = collection.xml
xml.xpath(SEED_XPATH).children.before(SEED_XML)
xml.xpath(CONV_XPATH).first.add_child(ARGS_XML)
collection.set_xml(xml)

collection.crawler_start
collection.wait_until_idle

##2. Perform Null Search to get document list, check for correctness
results = collection.search
docs = results.xpath(DOCS_XPATH)

validate_docs(docs, test_results)


#Cleanup
test_results.cleanup_and_exit!
