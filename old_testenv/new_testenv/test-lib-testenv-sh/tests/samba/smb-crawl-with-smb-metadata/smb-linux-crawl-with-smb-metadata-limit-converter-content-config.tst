#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

###################################
#
#   Fixed Data
#
queries = {"Hamilton"         => 4,
           "Hamilton Madison" => 4,
           "Linux"            => 3,
           "QueryThatWillNotMatchAnyDocuments"     => 0,
           "root"     => 47,
           "2009"     => 1,
           "2007"     => 47,
           "We the people"    => 10}

crawler_config =  <<"LINUXXML"
     <crawl-options>
       <crawl-option name="n-fetch-threads">10</crawl-option>
       <curl-option name="filter-exact-duplicates"><![CDATA[false]]></curl-option>
       <curl-option name="converter-max-memory">512</curl-option>
     </crawl-options>
     <call-function name="vse-crawler-seed-smb">
       <with name="host"><![CDATA[testbed5.bigdatalab.ibm.com]]></with>
       <with name="shares"><![CDATA[/testfiles/samba_test_data/samba-1/doc]]></with>
       <with name="username"><![CDATA[root]]></with>
       <with name="password"><![CDATA[{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==]]></with>
       <with name="crawl-fs-metadata">true</with>
     </call-function>
     <call-function elt-id="126" name="vse-crawler-smb-control-crawled-content-by-url">
        <with name="by-default-crawl" elt-id="127">metadata and content</with>
        <with name="patterns" elt-id="128">smb://*.pdf</with>
     </call-function>

LINUXXML

#
###################################

test_results = TestResults.new("Samba crawl of samba data AND metadata for linux with limit converter on content configuration")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

collection.delete
collection.create("default")

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
collection.set_xml(xml)

msg "Starting crawl"
collection.clean
collection.crawler_start
collection.wait_until_crawler_stopped
msg "Crawl finished"

queries.each do | query, expected |
   source_xpath = "/query-results/added-source"
   result = collection.search(query, {:output_duplicates => true})
   n_returned = result.xpath(source_xpath).first['total-results'].to_i
   test_results.add_number_equals(expected, n_returned, "'#{query}' result")
end

test_results.cleanup_and_exit!
