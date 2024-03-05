#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/mail'

require 'imap-test'

CRAWLER_CONFIG = <<XML
<crawl-options>
  <curl-option name="enable-acl">
    <![CDATA[false]]>
  </curl-option>
</crawl-options>
<call-function name="vse-crawler-seed-imap">
  <with name="username"><![CDATA[lay-k]]></with>
  <with name="password"><![CDATA[{vcrypt}Ctf3p48jE36OcjiBMfXaKA==]]></with>
  <with name="host"><![CDATA[testbed1-1.test.vivisimo.com]]></with>
  <with name="port"><![CDATA[993]]></with>
  <with name="secure"><![CDATA[secure]]></with>
</call-function>
XML

INDEXER_CONFIG = <<XML
  <vse-index-option name="duplicate-elimination">false</vse-index-option>
  <vse-index-option name="summarize-contents"><![CDATA[snippet]]></vse-index-option>
  <vse-url-equivs name="vse-url-equivs">
    <vse-url-equiv old-prefix="smb://" new-prefix="file://///" />
  </vse-url-equivs>
XML

EXPECTED_N_DOCS = 5937
QUERIES_AND_RESULTS = {"Arizona" => 10, "Bismarck" => 1, "Kenneth" => 2957,
                       "Kenneth Lay" => 2957, "screwed" => 3, "" => 5937}

test = ImapTest.new("This test crawls an email store and performs some queries"\
                    "to make the sure the index is in an expected state.\nDedu"\
                    "plication has been disabled in the indexer, and the login"\
                    " information has changed from imaps-1")

test.initialize_collection(CRAWLER_CONFIG, INDEXER_CONFIG)

test.run(EXPECTED_N_DOCS, QUERIES_AND_RESULTS)
