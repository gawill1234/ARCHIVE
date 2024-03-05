#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/replicated-synch/'
$LOAD_PATH << '.'
require 'misc'
require 'dstidx-resolve-conflicts-helper'

results = TestResults.new('URL conflicts should be resolved in favor of the latest timestamp when combining distributed indexing with light crawler')
results.need_system_report = false

msg "Newer crawl-url wins against older crawl-url"
foo, bar = configure_remote_server_and_client(results)
crawl_xml_and_stop_crawler(foo, CRAWL_URL_START + OLD_DATA + CRAWL_URL_END)
sleep(10)
crawl_xml_and_stop_crawler(bar, CRAWL_URL_START + NEW_DATA + CRAWL_URL_END)
resume_crawler_and_wait_for_idle(foo)
resume_crawler_and_wait_for_idle(bar)
results.add_equals(0, number_of_documents(foo, OLD_DATA), "number of old documents on first collection")
results.add_equals(0, number_of_documents(bar, OLD_DATA), "number of old documents on second collection")
results.add_equals(1, number_of_documents(foo, NEW_DATA), "number of new documents on first collection")
results.add_equals(1, number_of_documents(bar, NEW_DATA), "number of new documents on second collection")

msg "Newer orphaned crawl-delete wins against older crawl-url"
foo, bar = configure_remote_server_and_client(results)
crawl_xml_and_stop_crawler(foo, CRAWL_URL_START + OLD_DATA + CRAWL_URL_END)
sleep(10)
crawl_xml_and_stop_crawler(bar, CRAWL_DELETE)
resume_crawler_and_wait_for_idle(foo)
resume_crawler_and_wait_for_idle(bar)
results.add_equals(0, number_of_documents(foo, OLD_DATA), "number of documents on first collection")
results.add_equals(0, number_of_documents(bar, OLD_DATA), "number of documents on second collection")

msg "Newer crawl-url wins against older orphaned crawl-delete"
foo, bar = configure_remote_server_and_client(results)
crawl_xml_and_stop_crawler(foo, CRAWL_DELETE)
sleep(10)
crawl_xml_and_stop_crawler(bar, CRAWL_URL_START + OLD_DATA + CRAWL_URL_END)
resume_crawler_and_wait_for_idle(foo)
resume_crawler_and_wait_for_idle(bar)
results.add_equals(1, number_of_documents(foo, OLD_DATA), "number of documents on first collection")
results.add_equals(1, number_of_documents(bar, OLD_DATA), "number of documents on second collection")

msg "Newer non-orphaned crawl-delete wins against older crawl-url"
foo, bar = configure_remote_server_and_client(results)
crawl_xml_and_stop_crawler(foo, CRAWL_URL_START + OLD_DATA + CRAWL_URL_END)
sleep(10)
crawl_xml_and_stop_crawler(bar, CRAWL_URL_START + NEW_DATA + CRAWL_URL_END)
crawl_xml_and_stop_crawler(bar, CRAWL_DELETE)
resume_crawler_and_wait_for_idle(foo)
resume_crawler_and_wait_for_idle(bar)
results.add_equals(0, number_of_documents(foo, OLD_DATA), "number of documents on first collection")
results.add_equals(0, number_of_documents(bar, OLD_DATA), "number of documents on second collection")

msg "Newer crawl-url wins against older non-orphaned crawl-delete"
foo, bar = configure_remote_server_and_client(results)
crawl_xml_and_stop_crawler(foo, CRAWL_URL_START + OLD_DATA + CRAWL_URL_END)
crawl_xml_and_stop_crawler(foo, CRAWL_DELETE)
sleep(10)
crawl_xml_and_stop_crawler(bar, CRAWL_URL_START + NEW_DATA + CRAWL_URL_END)
resume_crawler_and_wait_for_idle(foo)
resume_crawler_and_wait_for_idle(bar)
results.add_equals(1, number_of_documents(foo, NEW_DATA), "number of documents on first collection")
results.add_equals(1, number_of_documents(bar, NEW_DATA), "number of documents on second collection")
results.cleanup_and_exit!(true)
