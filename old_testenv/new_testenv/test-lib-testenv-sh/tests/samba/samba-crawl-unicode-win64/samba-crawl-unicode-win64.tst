#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl - Files with unicode - Windows 64 bit")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="n-fetch-threads">10</crawl-option>
    <curl-option name="max-data-size">21000000</curl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[testbed2.bigdatalab.ibm.com]]></with>
    <with name="shares"><![CDATA[/exported/samba_test_data/samba-3/doc]]></with>
    <with name="username"><![CDATA[administrator]]></with>
    <with name="password"><![CDATA[{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==]]></with>
  </call-function>
XML

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
collection.set_xml(xml)

msg "Starting crawl"
collection.crawler_start
collection.wait_until_idle
msg "Crawl finished"

test_results.add_number_equals(28, collection.index_n_docs, "indexed document")

queries = {"We the people"         => 2,
           "Search and seizure"    => 2,
           "Great Creator"         => 1,
           "shumoku0606_35328.xls" => 1,
           "06-331c_53528.pdf"     => 2}

queries.each do | query, expected |
  source_xpath = "/query-results/added-source"
  result = collection.search(query, {:output_duplicates => true})
  n_returned = result.xpath(source_xpath).first['total-results'].to_i
  test_results.add_number_equals(expected, n_returned, "'#{query}' result")
end

test_results.cleanup_and_exit!
