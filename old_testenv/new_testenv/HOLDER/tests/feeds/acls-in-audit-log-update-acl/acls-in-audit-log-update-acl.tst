#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'

require 'misc'
require 'collection'
require 'acls-in-audit-log-helper'

@test_results = TestResults.new("Given that activity feed data are being collected",
                                "When I update the ACLs of documents with ACLs",
                                "Then the audit log should have crawl-activity 'changes' nodes with the new ACLs that I can retrieve with search-collection-audit-log-retrieve")
@collection   = Collection.new("acls-in-audit-log")
setup

new_acl = "+corp\\user2"
update_document(:acl => new_acl)

check_audit_log(:entries => 2, :changed => ['acl'], :acl => new_acl)

@test_results.cleanup_and_exit!