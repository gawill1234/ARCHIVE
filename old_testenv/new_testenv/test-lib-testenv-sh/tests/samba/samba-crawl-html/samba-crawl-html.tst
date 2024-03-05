#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl test - html")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="n-fetch-threads">10</crawl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[#{ENV['VIV_SAMBA_LINUX_SERVER']}]]></with>
    <with name="shares"><![CDATA[/#{ENV['VIV_SAMBA_LINUX_SHARE']}/test_data/law/US/360]]></with>
    <with name="username"><![CDATA[#{ENV['VIV_SAMBA_LINUX_USER']}]]></with>
    <with name="password"><![CDATA[#{ENV['VIV_SAMBA_LINUX_PASSWORD']}]]></with>
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

queries = {"Plaintiff" => 7,
           "1959" => 47,
           "1958" => 17,
           "UNITED STATES COURT OF APPEALS" => 36,
           "violation" => 19,
           "appeal" => 40}

queries.each do | query, expected |
  source_xpath = "/query-results/added-source"
  result = collection.search(query, {:output_duplicates => true})
  n_returned = result.xpath(source_xpath).first['total-results'].to_i
  test_results.add_number_equals(expected, n_returned, "'#{query}' result")
end

test_results.cleanup_and_exit!
