#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'

require 'misc'
require 'collection'
require 'acls-in-audit-log-helper'

@test_results = TestResults.new("Given that activity feed data are being collected",
                                "When I delete a document with an ACL",
                                "Then the audit log should have crawl-activity 'deleted' nodes with the same ACLs that I can retrieve with search-collection-audit-log-retrieve")
@collection   = Collection.new("acls-in-audit-log")
setup

delete_document

check_audit_log(:entries => 2, :deleted => 'true')

@test_results.cleanup_and_exit!