#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

def verify_queries(test_results, collection)
  test_results.add_number_equals(2152, collection.index_n_docs, "indexed document")

  queries = {"Hamilton"                              => 757,
             "Hamilton Madison"                      => 443,
             "Linux"                                 => 826,
             "QueryThatWillNotMatchAnyDocuments"     => 0,
             "We the people"                         => 1238,
             ""                                      => 2152}

  queries.each do | query, expected |
    source_xpath = "/query-results/added-source"
    result = collection.search(query)
  n_returned = result.xpath(source_xpath).first['total-results'].to_i
  test_results.add_number_equals(expected, n_returned, "'#{query}' result")
  end
end

test_results = TestResults.new("Samba large crawl test - full merge")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="full-merge">true</crawl-option>
    <crawl-option name="n-fetch-threads">10</crawl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[#{ENV['VIV_SAMBA_LINUX_SERVER']}]]></with>
    <with name="shares"><![CDATA[/#{ENV['VIV_SAMBA_LINUX_SHARE']}/samba_test_data/samba-2/doc]]></with>
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

verify_queries(test_results, collection)

collection.full_merge
collection.wait_until_idle

verify_queries(test_results, collection)

test_results.cleanup_and_exit!
