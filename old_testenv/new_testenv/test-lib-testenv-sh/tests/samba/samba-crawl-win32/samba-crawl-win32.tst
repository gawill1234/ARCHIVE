#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl test basic from 32 bit Windows machine")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="n-fetch-threads">10</crawl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[testbed8.test.vivisimo.com]]></with>
    <with name="shares"><![CDATA[/exported/samba_test_data/samba-1/doc]]></with>
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

test_results.add_number_equals(47, collection.index_n_docs, "indexed document")

queries = {"Hamilton"                          => 5,
           "Hamilton Madison"                  => 5,
           "Linux"                             => 6,
           "QueryThatWillNotMatchAnyDocuments" => 0,
           "We the people"                     => 19}

queries.each do | query, expected |
  source_xpath = "/query-results/added-source"
  result = collection.search(query, {:output_duplicates => true})
  n_returned = result.xpath(source_xpath).first['total-results'].to_i
  test_results.add_number_equals(expected, n_returned, "'#{query}' result")
end

test_results.cleanup_and_exit!
