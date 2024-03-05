#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'repl-synch-common'
require 'collection'
require 'misc'
require 'audit_log_helper'

# ------------------ Configuration ------------------

# REMOVE_LIGHT_CRAWLER: keep at "true", unless need to test
#   with light crawler
REMOVE_LIGHT_CRAWLER = true
# ADD_CALLBACK_CONFIGURATION : keep at "false", unless testing
#   this special configuration
ADD_CALLBACK_CONFIGURATION = false

def setup(results, server_name, client_name, port)
  msg "Setting up server and client"

  server, client = setup_server_and_client(server_name, client_name,
                     port, "finished")

  results.associate(server)
  results.associate(client)

  if REMOVE_LIGHT_CRAWLER
    remove_light_crawler(server)
    remove_light_crawler(client)
  end

  if ADD_CALLBACK_CONFIGURATION
     configure_remote_server(client, "dummy", 9090)
  end

  msg "Starting collections..."
  [server, client].each do |collection|
    collection.crawler_start
    collection.indexer_start
  end
  msg "Done starting collections."
  [server, client]
end

# ----------------------- Enqueue details ------------------------

def wrap(urls)
  '<crawl-urls synchronization="indexed-no-sync" > %s </crawl-urls>' % urls
end

def enqueue_and_verify(host, results, url, url_data)
  crawl_url = '<crawl-url url="http://%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued"><crawl-data encoding="xml" content-type="application/vxml"><document><content name="field1">%s</content></document></crawl-data></crawl-url>'

  results.add(host.enqueue_xml(wrap(crawl_url % [url, url_data])),
            "Finished enqueuing #{url} to #{host.name}",
            "Failed to enqueue #{url} to #{host.name}")

  msg "Checking audit log on #{host.name}."
  check_and_purge_audit_log(host, results, "successful", 1)
end

def enqueue_and_verify_server(server, client, results, url, url_data)
  enqueue_and_verify(server, results, url, url_data)
  msg "Checking audit log on client for replicated entry."
  check_and_purge_audit_log(client, results, "successful", 1)
end

# Verify vs no-verify stands for checking audit log. We still check
# return value, even with no-verify
def delete_no_verify(host, results, url, expected_deletes=1)
  crawl_delete = '<crawl-delete %s="http://%s" />'
  delete_status = host.enqueue_xml(wrap(crawl_delete % ["url", "#{url}"]))
  if expected_deletes > 0
    results.add(delete_status,
      "Deleted document with url #{url} from #{host.name}.",
      "Failed to delete document with url #{url} from #{host.name}."
    )
  else
    results.add(!delete_status,
      "As expected, failed to delete document with url #{url} from #{host.name}.",
      "Deleted document with url #{url} from #{host.name}. - shouldn't be able to"
    )
  end
end

def delete_and_verify(host, results, url, expected_deletes, expected_entries)
  delete_no_verify(host, results, url, expected_deletes)
  msg "Checking audit log on #{host.name}."
  check_audit_log_vse_key_deletes(host, results, "success", expected_deletes,
    sub=false)
  check_audit_log_vse_key_deletes(host, results, "error", 0, sub=false)
  check_and_purge_audit_log(host, results, "successful", expected_entries)
end

# ---------------- Tests ----------------- #

def print_test_header(title, description)
  puts "---------------------------"
  msg "#{title}:"
  puts "         #{description}"
end


# Bug 29149.
def url_deleted_on_client_can_be_deleted_on_server(server, client, results)
  print_test_header("Bug 29149",
    "Url deleted on client can be then deleted on server")

  enqueue_and_verify_server(server, client, results, "bug-29149",
     "bug-29149")
  delete_and_verify(client, results, "bug-29149", 1, 1)
  delete_and_verify(server, results, "bug-29149", 1, 1)

  check_audit_log_vse_key_deletes(client, results, "success", 0, sub=false)
  check_audit_log_vse_key_deletes(client, results, "error", 1, sub=false)

  check_and_purge_audit_log(client, results, "unsuccessful", 1)

  check_all_collections_are_synchronized([server, client], results)

  msg("Note: System report should show expected error "\
      "CRAWLER_DELETE_NO_RECORD (severity error-low) and nothing more severe")
end


# ----------------- Main ------------------ #

results = TestResults.new('Distributed indexing tests without light crawler. ',
            'Configuration consists of one server and one client. ',
            'May grow into a set of tests; for now has a test for ',
            'bug 29149')

results.need_system_report = true

SERVER_NAME = "repl-synch-1-s1"
CLIENT_NAME = "repl-synch-1-c1"
SERVER_PORT = "40411"

server, client = setup(results, SERVER_NAME, CLIENT_NAME, SERVER_PORT)

# Execute tests
url_deleted_on_client_can_be_deleted_on_server(server, client, results)

msg "-----------------------"
results.cleanup_and_exit!
