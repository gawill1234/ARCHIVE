#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl test - Multiple filetypes")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="n-fetch-threads">10</crawl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host" elt-id="2111">#{ENV['VIV_SAMBA_LINUX_SERVER']}</with>
    <with name="shares" elt-id="2112">/#{ENV['VIV_SAMBA_LINUX_SHARE']}/samba_test_data/11601/doc</with>
    <with name="username" elt-id="2113">#{ENV['VIV_SAMBA_LINUX_USER']}</with>
    <with name="password" elt-id="2114">#{ENV['VIV_SAMBA_LINUX_PASSWORD']}</with>
  </call-function>
XML

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
collection.set_xml(xml)

msg "Starting crawl"
collection.crawler_start
collection.wait_until_idle
msg "Crawl finished"

test_results.add_number_equals(26, collection.index_n_docs, "indexed document")

queries = {""        => 26,
           "slides"  => 4,
           "testbed" => 1,
           "simple"  => 9,
           "test"    => 26}

queries.each do | query, expected |
  source_xpath = "/query-results/added-source"
  result = collection.search(query, {:output_duplicates => true})
  n_returned = result.xpath(source_xpath).first['total-results'].to_i
  test_results.add_number_equals(expected, n_returned, "'#{query}' result")
end

test_results.cleanup_and_exit!
