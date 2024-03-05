#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/mail'

require 'imap-test'

CRAWLER_CONFIG = <<XML
<crawl-options>
  <curl-option name="enable-acl"><![CDATA[false]]></curl-option>
</crawl-options>
<call-function name="vse-crawler-seed-imap">
  <with name="username"><![CDATA[gaw]]></with>
  <with name="password"><![CDATA[{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==]]></with>
  <with name="host"><![CDATA[testbed1-1.test.vivisimo.com]]></with>
  <with name="port"><![CDATA[993]]></with>
  <with name="secure"><![CDATA[secure]]></with>
</call-function>
XML

test = ImapTest.new("This test attempts to crawl an email store with invalid "\
                    "login credentials, and should fail.")

test.initialize_collection(CRAWLER_CONFIG)

test.run(0)
