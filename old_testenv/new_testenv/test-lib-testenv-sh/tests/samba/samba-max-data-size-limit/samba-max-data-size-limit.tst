#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl - Max data size limit option")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

crawler_config = <<XML
  <crawl-options>
    <crawl-option name="n-fetch-threads">10</crawl-option>
    <curl-option name="converter-max-memory">1024</curl-option>
    <curl-option name="max-data-size">10000000</curl-option>
  </crawl-options>
  <call-function name="vse-crawler-seed-smb">
    <with name="host"><![CDATA[testbed2.test.vivisimo.com]]></with>
    <with name="shares"><![CDATA[/exported/samba_test_data/samba-4/doc/external_docs/failed_convert/5_2292178.pdf]]></with>
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
# Make sure the crawler is not just idle, but stopped.
# Otherwise, the url status query will fail if the crawler is in the process of terminating.
collection.wait_until_crawler_stopped
msg "Crawl finished"

url_status_response = collection.vapi.search_collection_url_status_query(:collection => collection.name, :crawl_url_status => '<crawl-url-status/>')
crawl_urls = url_status_response.xpath("//crawl-url")
url = url_status_response.xpath("string(//crawl-url/@url)")
error_id = url_status_response.xpath("string(//error/@id)")
test_results.add_equals(1, crawl_urls.count, "crawl url count")
test_results.add_matches(".*5_2292178.pdf", url, :what => "crawl url")
test_results.add_equals("CONVERTER_TOO_LARGE", error_id, "crawl url error status")

test_results.cleanup_and_exit!
