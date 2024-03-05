#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

test_results = TestResults.new("Samba crawl test with document checks. Asserts correct number of indexed",
                               "documents, correct number of results per query, correct number of matches",
                               "per document, and correct titles.")

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
    <with name="shares"><![CDATA[/#{ENV['VIV_SAMBA_LINUX_SHARE']}/samba_test_data/samba-1/doc]]></with>
    <with name="username"><![CDATA[#{ENV['VIV_SAMBA_LINUX_USER']}]]></with>
    <with name="password"><![CDATA[#{ENV['VIV_SAMBA_LINUX_PASSWORD']}]]></with>
  </call-function>
XML
indexer_config = <<XML
  <vse-index-option name="ranking-n-best">5</vse-index-option>
  <vse-url-equivs name="vse-url-equivs">
    <vse-url-equiv old-prefix="smb://" new-prefix="file://///"/>
  </vse-url-equivs>
XML

xml = collection.xml
xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
xml.xpath("/vse-collection/vse-config/vse-index").children.before(indexer_config)
collection.set_xml(xml)

msg "Starting crawl"
collection.crawler_start
collection.wait_until_idle
msg "Crawl finished"

test_results.add_number_equals(47, collection.index_n_docs, "indexed document")

output_axl = <<XML
<process-xsl><![CDATA[
  <xsl:variable name="doc" select="vse:document()" />
  <document>
    <xsl:attribute name="number-of-matches"><xsl:value-of select="count(vse:current-result(true())//r)"/></xsl:attribute>
    <xsl:copy-of select="$doc/@*|$doc/*" />
    <xsl:copy-of select="vse:contents()" />
    <xsl:copy-of select="vse:summarize()" />
  </document>
]]></process-xsl>
XML

queries = {
"Hamilton"         => {"total-results" => 5,
                       "number-of-matches" => [2, 2, 2, 2, 5],
                       "titles" => ["CONSTITUTION",
                                    "The Federalist - Contents" ]},
"Hamilton Madison" => {"total-results" => 5,
                       "number-of-matches" => [2, 2, 2, 2, 5],
                       "titles" => ["CONSTITUTION",
                                    "The Federalist - Contents" ]},
"Linux"            => {"total-results" => 6,
                       "number-of-matches" => [2, 5, 5, 5, 5, 5],
                       "titles" => ["An Introduction to Heritrix An open source archival quality web crawler Abstract",
                                    "SUSE LINUX",
                                    "SUSE LINUX",
                                    "MARKET ANALYSIS Worldwide Content Access Tools (Search and Retrieval) 2005–2009 Forecast and 2004 Vendor Shares",
                                    "Easysoft Data Access",
                                    "Oracle® Database"]},
"QueryThatWillNotMatchAnyDocuments" => {"total-results" => 0,
                                        "number-of-matches" => [],
                                        "titles" => []},
"We the people"    => {"total-results" => 19,
                       "number-of-matches" => [5, 4, 1, 1, 5, 5, 5, 1, 1, 1, 1, 1, 5, 5, 5, 5, 1, 5, 5],
                       "titles" => ["Data Structures, Algorithms and Implementation Issues Overview",
                                    "Data Structures, Algorithms and Implementation Issues Inverted List Indexes: Access Methods",
                                    "Magic Quadrant for Information Access Technology, 2005",
                                    "Preamble & Bill of Rights.pdf",
                                    "Tips and Tricks for Using Microsoft Office SharePoint Portal Server 2003",
                                    "SUSE LINUX",
                                    "SUSE LINUX",
                                    "CONSTITUTION",
                                    "Thomas Jefferson: Original Rough Draft of the Declaration of Independence",
                                    "Easysoft Data Access",
                                    "The Federalist - Contents",
                                    "The Gettysburg Address",
                                    "Declaration of Independence"]},
"Drahtmüller"      => {"total-results" => 1,
                       "number-of-matches" => [1],
                       "titles" => ["SUSE LINUX"]}
}

def get_total_results(query_result)
  source_xpath = "/query-results/added-source"
  query_result.xpath(source_xpath).first['total-results'].to_i
end

def get_sorted_documents(query_result)
  query_result.xpath('//document').sort{ |x, y| x.attr('url') <=> y.attr('url') }
end

def get_number_of_matches(sorted_documents)
  sorted_documents.to_a.map{ |document| document.attr('number-of-matches').to_i }
end

def get_document_titles(sorted_documents)
  sorted_documents.to_a.map{ |document| document.xpath('content[@name="title"]') }.reject(&:empty?).map(&:text)
end

queries.each do | query, expected |
  query_result = collection.search(query, {:num => 200, :output_duplicates => true, :output_axl => output_axl})

  total_results = get_total_results(query_result)
  test_results.add_number_equals(expected['total-results'], total_results, "'#{query}' result")

  sorted_documents = get_sorted_documents(query_result)

  number_of_matches = get_number_of_matches(sorted_documents)
  test_results.add_equals(expected['number-of-matches'], number_of_matches, "'#{query}' match count")

  document_titles = get_document_titles(sorted_documents)
  test_results.add_equals(expected['titles'], document_titles, "'#{query}' title list")
end

test_results.cleanup_and_exit!
