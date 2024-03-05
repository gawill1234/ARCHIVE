#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']
$LOAD_PATH << '.'

require 'misc'
require 'audit-log-enabled-helper'

@test_results = TestResults.new("Velocity should throw an exception when a user enqueues with the originator attribute but the audit log is not enabled")
@collection   = Collection.new(TESTENV.test_name)

setup
msg "Disabling the audit log"
disable_audit_log

msg "Enqueuing a crawl-url with an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_URL) == true, 
                  "crawl-url with originator attribute yields proper exception")

msg "Enqueuing a crawl-url with an originator attribute as a child of a crawl-urls node"
@test_results.add(enqueue_generated_exception(CRAWL_URLS_CRAWL_URL) == true, 
                  "crawl-url with originator attribute as a child of a crawl-urls node yields proper exception")

msg "Enqueuing a crawl-urls node with an originator attribute"

@test_results.add(enqueue_generated_exception(CRAWL_URLS) == true, 
                  "crawl-urls node with originator attribute yields proper exception")

msg "Enqueuing a crawl-delete node with an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_DELETE) == true, 
                  "crawl-delete node with originator attribute yields proper exception")

msg "Enqueuing a crawl-urls node containing a crawl-delete node with an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_URLS_CRAWL_DELETE) == true, 
                  "crawl-delete node with originator attribute as a child of a crawl-urls node yields proper exception")

msg "Enqueuing an index-atomic with an originator attribute as a child of a crawl-urls node"
@test_results.add(enqueue_generated_exception(CRAWL_URLS_INDEX_ATOMIC) == true, 
                  "index-atomic with originator attribute as a child of a crawl-urls node yields proper exception")

msg "Enqueuing an index-atomic with an originator attribute"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC) == true, 
                  "index-atomic with originator attribute yields proper exception")

msg "Enqueuing an index-atomic with an originator attribute"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC) == true, 
                  "index-atomic with originator attribute yields proper exception")

msg "Enqueuing a crawl-url with an originator attribute as a child of an index-atomic"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC_CRAWL_URL) == true, 
                  "crawl-url with originator attribute as a child of an index-atomic node yields proper exception")

msg "Enqueuing a crawl-delete with an originator attribute as a child of an index-atomic"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC_CRAWL_DELETE) == true, 
                  "crawl-delete with originator attribute as a child of an index-atomic node yields proper exception")

msg "Enqueuing a crawl-url without an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_URL_WITHOUT_ORIGINATOR) == false, 
                  "crawl-url with originator attribute does not yield exception")

msg "Recreating collection"
setup
msg "Enabling the audit log"
enable_audit_log

msg "Enqueuing a crawl-url with an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_URL) == false, 
                  "crawl-url with originator attribute does not yield exception")

msg "Enqueuing a crawl-url with an originator attribute as a child of a crawl-urls node"
@test_results.add(enqueue_generated_exception(CRAWL_URLS_CRAWL_URL) == false, 
                  "crawl-url with originator attribute as a child of a crawl-urls node does not yield exception")

msg "Enqueuing a crawl-urls node with an originator attribute"

@test_results.add(enqueue_generated_exception(CRAWL_URLS) == false, 
                  "crawl-urls node with originator attribute does not yield exception")

msg "Enqueuing a crawl-delete node with an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_DELETE) == false, 
                  "crawl-delete node with originator attribute does not yield  exception")

msg "Enqueuing a crawl-urls node containing a crawl-delete node with an originator attribute"
@test_results.add(enqueue_generated_exception(CRAWL_URLS_CRAWL_DELETE) == false, 
                  "crawl-delete node with originator attribute as a child of a crawl-urls node does not yield exception")

msg "Enqueuing an index-atomic with an originator attribute as a child of a crawl-urls node"
@test_results.add(enqueue_generated_exception(CRAWL_URLS_INDEX_ATOMIC) == false, 
                  "index-atomic with originator attribute as a child of a crawl-urls node does not yield exception")

msg "Enqueuing an index-atomic with an originator attribute"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC) == false, 
                  "index-atomic with originator attribute does not yield exception")

msg "Enqueuing an index-atomic with an originator attribute"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC) == false, 
                  "index-atomic with originator attribute does not yield exception")

msg "Enqueuing a crawl-url with an originator attribute as a child of an index-atomic"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC_CRAWL_URL) == false, 
                  "crawl-url with originator attribute as a child of an index-atomic node does not yield exception")

msg "Enqueuing a crawl-delete with an originator attribute as a child of an index-atomic"
@test_results.add(enqueue_generated_exception(INDEX_ATOMIC_CRAWL_DELETE) == false, 
                  "crawl-delete with originator attribute as a child of an index-atomic node does not yield exception")
@test_results.cleanup_and_exit!
