#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# Test: bug-28974
#
# Test that the silly converter that copies files into
# vivisimo temp files allows us to convert .doc files
# with non-ASCII filenames.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'gronk'
require 'misc'
require 'nokogiri'

# Constants
velocity        = TESTENV.velocity
user            = TESTENV.user
password        = TESTENV.password
CHINESE_DOC     = "中華傲訣.doc"
BUG_NUMBER      = "bug-28974"
CONVERTER_XPATH = "//converters"
SEED_XPATH      = "//crawler"
ASCII_CONVERTER = "<converter type-out=\"application/word\" type-out=\"applica"\
                  "tion/word\"><call-function name=\"vse-converter-non-ascii-n"\
                  "ames\" /></converter"
SEARCH_TERM     = "我命犯天煞"
DOC_TITLE       = "中華傲訣"
TITLE_XPATH     = "//content[@name='title']"

vapi = Vapi.new(velocity, user, password)

test_results = TestResults.new(BUG_NUMBER, "Test the copy-file function we use"\
                               " to copy word documents to temp files so that "\
                               "our .doc converter will process non-ascii file"\
                               "names.")

# Use gronk to send our special file to Velocity's local fs
gronk = Gronk.new
if ENV['VIVTARGETOS'] == "windows"
  crawl_dir = gronk.installed_dir.gsub("\\", "\\\\\\").gsub(" ", "\\\ ")
  crawl_dir = "#{crawl_dir}\\\\tmp"
  seed_version_crawl_dir     = "#{gronk.installed_dir.gsub('\\', '/')}/tmp"
  # When the file is written to Windows, it gets this weird name.
  # All that we actually care about is that it's got non-ascii characters in it,
  # so this is file as long as we know to look for it on Windows only.
  seed_version_document_name = "ä¸­è¯å‚²è¨£.doc"
else
  crawl_dir                  = gronk.installed_dir
  seed_version_crawl_dir     = crawl_dir
  seed_version_document_name = CHINESE_DOC
end

# One last more variable to set, now that we can
SEED_XML        = "<call-function name=\"vse-crawler-seed-files\" type=\"crawl"\
                  "-seed\"><with name=\"files\">#{seed_version_crawl_dir}/#{seed_version_document_name}<"\
                  "/with></call-function>"

`put_file -F #{CHINESE_DOC} -D #{crawl_dir}`

#Create a collection
collection = Collection.new(BUG_NUMBER, velocity, user, password)
collection.delete
collection.create("default")

#Update the collection's xml to use the relevant converter
#and set the seed to the 'chinese' folder
xml = Nokogiri::XML(collection.xml.to_s)
xml.xpath(CONVERTER_XPATH).children.before(ASCII_CONVERTER)
xml.xpath(SEED_XPATH).children.before(SEED_XML)
collection.set_xml(xml)
collection.crawler_start
sleep(10)
result = Nokogiri::XML(collection.search(SEARCH_TERM).to_s)
if result.xpath(TITLE_XPATH).first
  if result.xpath(TITLE_XPATH).first.content == DOC_TITLE
    test_results.add_success("Document successfully crawled!")
  else
    test_results.add_failure("Chinese Document was not properly parsed. The quer"\
                             "y returned:" << result.to_s)
  end
else
  test_results.add_failure("No results in the collection - maybe the file isn't present?")
end
gronk.rm_file("#{crawl_dir}/#{CHINESE_DOC}")
collection.delete
test_results.cleanup_and_exit!
