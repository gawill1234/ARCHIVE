#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/mail'

require 'imap-test'

CRAWLER_CONFIG = <<XML
<crawl-options>
  <curl-option name="enable-acl"><![CDATA[false]]></curl-option>
</crawl-options>
<call-function name="vse-crawler-seed-imap">
  <with name="username"><![CDATA[skilling-j]]></with>
  <with name="password"><![CDATA[{vcrypt}Ctf3p48jE36OcjiBMfXaKA==]]></with>
  <with name="host"><![CDATA[testbed1-1.test.vivisimo.com]]></with>
  <with name="port"><![CDATA[993]]></with>
  <with name="secure"><![CDATA[secure]]></with>
</call-function>
XML
INDEXER_CONFIG = <<XML
<vse-index-option name="summarize-contents">
  <![CDATA[snippet]]>
</vse-index-option>
<vse-url-equivs name="vse-url-equivs">
  <vse-url-equiv old-prefix="smb://" new-prefix="file://///" />
</vse-url-equivs>
XML

EXPECTED_N_DOCS = 4131
QUERIES_AND_RESULTS = {"Arizona" => 13, "Bismarck" => 0, "Kenneth" => 457,
                       "Kenneth Lay" => 403, "screwed" => 1, "" => 4131}

test = ImapTest.new("This test crawls an email store and performs some perfunc"\
                    "functory queries to check that it succeeded. There are no"\
                    " special settings for this test.")

test.initialize_collection(CRAWLER_CONFIG, INDEXER_CONFIG)

test.run(EXPECTED_N_DOCS, QUERIES_AND_RESULTS)
