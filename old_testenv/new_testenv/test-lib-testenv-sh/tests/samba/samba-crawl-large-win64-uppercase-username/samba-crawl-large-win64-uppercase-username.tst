#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl test - Large Windows 64 bit samba crawl and search of various doc types using uppercase username")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="n-fetch-threads">10</crawl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[testbed2.bigdatalab.ibm.com]]></with>
    <with name="shares"><![CDATA[/exported/samba_test_data/samba-2/doc]]></with>
    <with name="username"><![CDATA[ADMINISTRATOR]]></with>
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

test_results.add_number_equals(2152, collection.index_n_docs, "indexed document")

queries = {"Hamilton"                          => 757,
           "Hamilton Madison"                  => 443,
           "Linux"                             => 826,
           "QueryThatWillNotMatchAnyDocuments" => 0,
           "We the people"                     => 1238,
           ""                                  => 2152}

queries.each do | query, expected |
  source_xpath = "/query-results/added-source"
  result = collection.search(query, {:output_duplicates => true})
  n_returned = result.xpath(source_xpath).first['total-results'].to_i
  test_results.add_number_equals(expected, n_returned, "'#{query}' result")
end

test_results.cleanup_and_exit!
