#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/feeds'
$LOAD_PATH << '.'

require 'misc'
require 'collection'
require 'feed-helper'
require 'has-changes-helper'

@test_results = TestResults.new("The activity feed option should set the types of activities created.")
@collection   = Collection.new(TESTENV.test_name)

setup
msg "When 'all' activities are enabled"
enable_activity_feed('all')
msg "  Enqueuing url with single crawl-data and single document"
enqueue_url_with_single_crawl_data_and_single_document
msg "    Document is new, should have one activity"
check_documents(:number => 1)
purge_audit_log
msg "  Re-enqueuing same document"
enqueue_url_with_single_crawl_data_and_single_document
msg "    Document is not changing, should still create activity"
check_documents(:number => 1)
purge_audit_log
msg "  Enqueuing changed document"
enqueue_url_with_single_crawl_data_and_single_document(:document_change => "changed")
msg "    Document is changing, should create activity"
check_documents(:number => 1)
purge_audit_log
msg "  Enqueuing url with single crawl-data and multiple documents"
enqueue_url_with_single_crawl_data_and_multiple_documents
msg "    Documents are new, should have two activities"
check_documents(:number => 2)
purge_audit_log
msg "  Re-enqueuing same documents"
enqueue_url_with_single_crawl_data_and_multiple_documents
msg "    Documents are not changing, should still create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to first document"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "changed")
msg "    First document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to second document"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "changed", :second_document_change => "second change")
msg "    Second document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to both documents"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "new change", :second_document_change => "another new change")
msg "    Both documents are changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing url with multiple crawl-data elements"
enqueue_url_with_multiple_crawl_data
msg "    Documents are new, should have two activities"
check_documents(:number => 2)
purge_audit_log
msg "  Re-enqueuing same documents"
enqueue_url_with_multiple_crawl_data
msg "    Documents are not changing, should still create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to first document"
enqueue_url_with_multiple_crawl_data(:first_document_change => "changed")
msg "    First document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to second document"
enqueue_url_with_multiple_crawl_data(:first_document_change => "changed", :second_document_change => "another change")
msg "    Second document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to both documents"
enqueue_url_with_multiple_crawl_data(:first_document_change => "new change", :second_document_change => "another new change")
msg "    Both documents are changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log

setup
msg "When activities 'only-for-urls-with-changes' are enabled"
enable_activity_feed('only-for-urls-with-changes')
msg "  Enqueuing url with single crawl-data and single document"
enqueue_url_with_single_crawl_data_and_single_document
msg "    Document is new, should have one activity"
check_documents(:number => 1)
purge_audit_log
msg "  Re-enqueuing same document"
enqueue_url_with_single_crawl_data_and_single_document
msg "    Document is not changing, should not create activity"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing changed document"
enqueue_url_with_single_crawl_data_and_single_document(:document_change => "changed")
msg "    Document is changing, should create activity"
check_documents(:number => 1)
purge_audit_log
msg "  Enqueuing url with single crawl-data and multiple documents"
enqueue_url_with_single_crawl_data_and_multiple_documents
msg "    Documents are new, should have two activities"
check_documents(:number => 2)
purge_audit_log
msg "  Re-enqueuing same documents"
enqueue_url_with_single_crawl_data_and_multiple_documents
msg "    Documents are not changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to first document"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "changed")
msg "    First document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to second document"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "changed", :second_document_change => "second change")
msg "    Second document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to both documents"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "new change", :second_document_change => "another new change")
msg "    Both documents are changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing url with multiple crawl-data elements"
enqueue_url_with_multiple_crawl_data
msg "    Documents are new, should have two activities"
check_documents(:number => 2)
purge_audit_log
msg "  Re-enqueuing same documents"
enqueue_url_with_multiple_crawl_data
msg "    Documents are not changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to first document"
enqueue_url_with_multiple_crawl_data(:first_document_change => "changed")
msg "    First document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to second document"
enqueue_url_with_multiple_crawl_data(:first_document_change => "changed", :second_document_change => "another change")
msg "    Second document is changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log
msg "  Enqueuing change to both documents"
enqueue_url_with_multiple_crawl_data(:first_document_change => "new change", :second_document_change => "another new change")
msg "    Both documents are changing, should create activities for both"
check_documents(:number => 2)
purge_audit_log

setup
msg "When activities are disabled"
enable_activity_feed('disabled')
msg "  Enqueuing url with single crawl-data and single document"
enqueue_url_with_single_crawl_data_and_single_document
msg "    Document is new, should not create activity"
check_documents(:number => 0)
purge_audit_log
msg "  Re-enqueuing same document"
enqueue_url_with_single_crawl_data_and_single_document
msg "    Document is not changing, should not create activity"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing changed document"
enqueue_url_with_single_crawl_data_and_single_document(:document_change => "changed")
msg "    Document is changing, should not create activity"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing url with single crawl-data and multiple documents"
enqueue_url_with_single_crawl_data_and_multiple_documents
msg "    Documents are new, should have no activities"
check_documents(:number => 0)
purge_audit_log
msg "  Re-enqueuing same documents"
enqueue_url_with_single_crawl_data_and_multiple_documents
msg "    Documents are not changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to first document"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "changed")
msg "    First document is changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to second document"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "changed", :second_document_change => "second change")
msg "    Second document is changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to both documents"
enqueue_url_with_single_crawl_data_and_multiple_documents(:first_document_change => "new change", :second_document_change => "another new change")
msg "    Both documents are changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing url with multiple crawl-data elements"
enqueue_url_with_multiple_crawl_data
msg "    Documents are new, should have no activities"
check_documents(:number => 0)
purge_audit_log
msg "  Re-enqueuing same documents"
enqueue_url_with_multiple_crawl_data
msg "    Documents are not changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to first document"
enqueue_url_with_multiple_crawl_data(:first_document_change => "changed")
msg "    First document is changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to second document"
enqueue_url_with_multiple_crawl_data(:first_document_change => "changed", :second_document_change => "another change")
msg "    Second document is changing, should not create activities"
check_documents(:number => 0)
purge_audit_log
msg "  Enqueuing change to both documents"
enqueue_url_with_multiple_crawl_data(:first_document_change => "new change", :second_document_change => "another new change")
msg "    Both documents are changing, should not create activities"
check_documents(:number => 0)
purge_audit_log

@test_results.cleanup_and_exit!
