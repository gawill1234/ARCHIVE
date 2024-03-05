#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'

require 'misc'
require 'collection'
require 'acls-in-audit-log-helper'

@test_results = TestResults.new("Given that activity feed data are being collected",
                                "When I add documents with ACLs to the collection",
                                "Then the audit log should have crawl-activity nodes with the same ACLs that I can retrieve with search-collection-audit-log-retrieve")
@collection   = Collection.new("acls-in-audit-log")
setup

check_audit_log

@test_results.cleanup_and_exit!