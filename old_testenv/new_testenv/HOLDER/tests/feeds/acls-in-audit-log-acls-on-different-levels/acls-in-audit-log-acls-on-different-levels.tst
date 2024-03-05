#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'

require 'misc'
require 'collection'
require 'acls-in-audit-log-helper'

@test_results = TestResults.new("Given that activity feed data are being collected",
                                "When I enqueue XML with ACLs at different levels",
                                "Then the audit log should have crawl-activity nodes with the most specific ACL given")
@collection   = Collection.new("acls-in-audit-log")
setup

check_content_acls
check_document_acls
check_crawl_data_acls
check_crawl_url_acls

@test_results.cleanup_and_exit!