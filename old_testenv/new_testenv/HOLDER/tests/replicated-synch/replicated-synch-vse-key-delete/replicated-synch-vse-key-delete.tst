#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'repl-synch-common'
require 'collection'
require 'misc'
require 'audit_log_helper'

# ----------------- Configuration ------------------

# REMOVE_LIGHT_CRAWLER: keep at "false", unless need to test
#   without light crawler
REMOVE_LIGHT_CRAWLER = false
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

def enqueue_and_verify(host_alias, host, results, url, vse_key, url_data)
  crawl_url = '<crawl-url url="http://%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued" forced-vse-key="%s" forced-vse-key-normalized="forced-vse-key-normalized"><crawl-data encoding="xml" content-type="application/vxml"><document><content name="field1">%s</content></document></crawl-data></crawl-url>'
  msg "Enqueueing #{url} with #{url_data} to #{host_alias}."

  results.add(host.enqueue_xml(wrap(crawl_url % [url, vse_key, url_data])),
            "Finished enqueuing #{url} to #{host_alias}",
            "Failed to enqueue #{url} to #{host_alias}")

  msg "Checking audit log on #{host_alias}."
  check_and_purge_audit_log(host, results, "successful", 1)
end

def enqueue_and_verify_server(server, client, results, url, vse_key, url_data)
  enqueue_and_verify("server", server, results, url, vse_key, url_data)
  msg "Checking audit log on client for replicated entry."
  check_and_purge_audit_log(client, results, "successful", 1)
end

# Verify vs no-verify stands for checking audit log. We still check
# return value, even with no-verify
def delete_no_verify(host_alias, host, results, vse_key, expected_deletes=1)
  crawl_delete = '<crawl-delete %s="%s" />'
  msg "Deleting by vse-key #{vse_key} from #{host_alias}"
  if expected_deletes > 0
    results.add(host.enqueue_xml(wrap(crawl_delete % ["vse-key", "#{vse_key}"])),
      "Deleted document with vse-key #{vse_key} from #{host_alias}.",
      "Failed to delete document with vse-key #{vse_key} from #{host_alias}."
    )
  else
    results.add(!(host.enqueue_xml(wrap(crawl_delete % ["vse-key", "#{vse_key}"]))),
      "As expected, failed to delete document with vse-key #{vse_key} from #{host_alias}.",
      "Deleted document with vse-key #{vse_key} from #{host_alias}. - shouldn't be able to"
    )
  end
end

def delete_and_verify(host_alias, host, results, vse_key,
      expected_deletes, expected_entries)
  delete_no_verify(host_alias, host, results, vse_key, expected_deletes)
  msg "Checking audit log on #{host_alias}."
  check_audit_log_vse_key_deletes(host, results, "success", expected_deletes)
  check_audit_log_vse_key_deletes(host, results, "error", 0)
  check_and_purge_audit_log(host, results, "successful", expected_entries)
end

def delete_and_verify_server(server, client, results, vse_key,
      expected_deletes_server, expected_entries_server,
      expected_deletes_client, expected_entries_client)
  delete_and_verify("server", server, results, vse_key,
                    expected_deletes_server, expected_entries_server)
  msg "Checking audit log on client."
  check_audit_log_vse_key_deletes(client, results, "success",
                                  expected_deletes_client)
  check_audit_log_vse_key_deletes(client, results, "error", 0)
  check_and_purge_audit_log(client, results, "successful",
                            expected_entries_client)
end

# ---------------- Tests ----------------- #

def print_test_header(title, description)
  puts "---------------------------"
  msg "#{title}:"
  puts "         #{description}"
end


# Test 0.
def value_enqueued_on_server_is_deleted(server, client, results)
  print_test_header("Test 0. Base case - enqueue on server only",
    "Value enqueued on server, replicated on client; "\
    "no extra entries on client. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from server and client")

  vse_key="server-only-key"

  enqueue_and_verify_server(server, client, results, "server-only",
    vse_key, "server-only")

  delete_and_verify_server(server, client, results, vse_key,
    expected_deletes_server=1,
    expected_entries_server=1,
    expected_deletes_client=1,
    expected_entries_client=2 # One for url delete and one for vse-key delete
  )
  check_all_collections_are_synchronized([server, client], results)
end

# Test 1.
def values_enqueued_on_server_and_client_are_deleted(server, client, results)
  print_test_header("Test 1. Enqueue on server and on client",
    "Value enqueued on server, replicated on client; another value "\
    "enqueued on client. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from server and client")

  vse_key="server-and-client-key"

  enqueue_and_verify_server(server, client, results, "url-on-server",
    vse_key, "url-on-server")
  enqueue_and_verify("client", client, results, "url-on-client",
    vse_key, "url-on-client")

  delete_and_verify_server(server, client, results, vse_key,
    expected_deletes_server=1,
    expected_entries_server=1,
    expected_deletes_client=2, # One for each url
    expected_entries_client=2  # One for urls delete and one for vse-key delete
  )
  check_all_collections_are_synchronized([server, client], results)
end

# Test 2.
def value_enqueued_on_client_is_deleted(server, client, results)
  print_test_header("Test 2. Enqueue on client only",
    "Nothing enqueued on server; a value enqueued on client; "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from server and client")

  vse_key="client-only-key"

  enqueue_and_verify("client", client, results, "client-only",
    vse_key, "client-only")

  delete_and_verify_server(server, client, results, vse_key,
    expected_deletes_server=0,
    expected_entries_server=0,
    expected_deletes_client=1,
    expected_entries_client=1 # Only vse-key delete
  )
  check_all_collections_are_synchronized([server, client], results)
end

# Test 3.
def value_deleted_on_client_does_not_affect_delete(server, client, results)
  print_test_header("Test 3. Replicated entry deleted on client",
    "A value is enqueued on server, replicated on client, "\
    "then deleted on client via vse-key delete. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from server and client")

  vse_key="replicated-entry-pre-deleted-key"

  enqueue_and_verify_server(server, client, results,
    "replicated-entry-to-be-pre-deleted", vse_key,
    "replicated-entry-to-be-pre-deleted")
  delete_and_verify("client", client, results, vse_key,
    expected_deletes=1,
    expected_entries=1)

  if REMOVE_LIGHT_CRAWLER
    # Without light crawler, when we send delete to the server, on client it is
    # detected that there is no such an entry in the collection,
    # so the response is state=error, siphoned=nonexistent.
    delete_and_verify_server(server, client, results, vse_key,
      expected_deletes_server=1,
      expected_entries_server=1,
      expected_deletes_client=0,
      expected_entries_client=0
    )
  else
    # With light crawler, the "existent/nonexistent" check is not performed,
    # so when we send delete to the server, delete is also written in
    # client audit log,
    # even though there is nothing to delete there.
    delete_and_verify_server(server, client, results, vse_key,
      expected_deletes_server=1,
      expected_entries_server=1,
      expected_deletes_client=1,
      expected_entries_client=1 # Only vse-key delete
    )
  end
  check_all_collections_are_synchronized([server, client], results)
end

# Test 4.
def multiple_entries_with_selected_vse_key_are_deleted(server, client, results)
  print_test_header("Test 4. Higher number of entries",
    "9 urls with the same vse-key are enqueued on server, replicated "\
    "on client; 5 more urls enqueued on client. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from server and client")

  vse_key="more-entries-key"

  (1..9).each do |j|
  enqueue_and_verify_server(server, client, results,
    "more-entries-on-server-#{j}", vse_key, "more-entries-on-server-#{j}")
  end
  (10..14).each do |j|
  enqueue_and_verify("client", client, results,
    "more-entries-on-client-#{j}", vse_key, "more-entries-on-client-#{j}")
  end

  delete_and_verify_server(server, client, results, vse_key,
    expected_deletes_server=9,
    expected_entries_server=1,
    expected_deletes_client=14,
    expected_entries_client=2 # One for urls delete and one for vse-key delete
  )
  check_all_collections_are_synchronized([server, client], results)
end

# Test 5.
def only_entries_with_selected_vse_key_are_deleted(server, client, results)
  print_test_header("Test 5. With other data on the server and the client",
    "Data added, then 2 urls with the same vse-key are enqueued on server, "\
    "replicated on client; 3 urls enqueued on client; more data added. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "with correct vse-key and leave the rest.")

  # First, adding ballast
  vse_key="ballast-before-key"

  (15..16).each do |j|
    enqueue_and_verify_server(server, client, results,
      "ballast-before-on-server-#{j}", vse_key, "ballast-before-on-server-#{j}")
  end
  (17..18).each do |j|
    enqueue_and_verify("client", client, results,
      "ballast-before-on-client-#{j}", vse_key, "ballast-before-on-client-#{j}")
  end

  # Now adding urls under test
  target_vse_key="target-key"

  (19..20).each do |j|
    enqueue_and_verify_server(server, client, results,
      "target-url-on-server-#{j}", target_vse_key, "target-url-on-server-#{j}")
  end
  (21..23).each do |j|
    enqueue_and_verify("client", client, results,
      "target-url-on-client-#{j}", target_vse_key, "target-url-on-client-#{j}")
  end

  # And now more ballast
  vse_key="data-after-key"

  (24..25).each do |j|
    enqueue_and_verify_server(server, client, results,
      "data-after-on-server-#{j}", vse_key, "data-after-on-server-#{j}")
  end
  (26..27).each do |j|
    enqueue_and_verify("client", client, results,
      "data-after-on-client-#{j}", vse_key, "data-after-on-client-#{j}")
  end

  # And finally delete
  delete_and_verify_server(server, client, results, target_vse_key,
    expected_deletes_server=2,
    expected_entries_server=1,
    expected_deletes_client=5,
    expected_entries_client=2 # One for urls and one for vse-key delete
  )

  check_all_collections_are_synchronized([server, client], results)
end

# Test 6.
def later_addition_on_client_is_not_deleted(server, client, results)
  print_test_header("Test 6. Later addition on client is not deleted",
    "Entries that were added on the client "\
    "after vse-key delete was processed on the server, "\
    "are not deleted.")

  vse_key="later-addition-key"

  enqueue_and_verify_server(server, client, results, "first-entry-on-server",
    vse_key, "first-entry-on-server")
  enqueue_and_verify_server(server, client, results, "second-entry-on-server",
    vse_key, "second-entry-on-server")
  msg "Stopping client"
  client.crawler_stop
  client.indexer_stop
  delete_no_verify("server", server, results, vse_key)
  msg "Stopping server"
  server.crawler_stop
  server.indexer_stop
  msg "Starting client"
  client.crawler_start
  client.indexer_start
  enqueue_and_verify("client", client, results, "later-addition-on-client",
    vse_key, "later-addition-on-client")
  msg "Starting server"
  server.crawler_start
  server.indexer_start
  msg "Checking audit log on server"
  check_audit_log_vse_key_deletes(server, results, "success", 2)
  check_and_purge_audit_log(server, results, "successful", 1)
  msg "Checking audit log on client"
  check_audit_log_vse_key_deletes(client, results, "success", 2)
  check_and_purge_audit_log(client, results, "successful", 2) # One for
    # urls and one for vse-key delete

  check_all_collections_are_synchronized([server, client], results)
end

# Test 7.
def later_update_on_client_is_not_deleted(server, client, results)
  print_test_header("Test 7. Later update on client is not deleted",
    "Entries that were updated on the client "\
    "after vse-key delete was processed on the server, "\
    "are not deleted.")

  vse_key="later-update-key"

  enqueue_and_verify_server(server, client, results,
    "unchanged-entry-on-server", vse_key, "unchanged-entry-on-server")
  enqueue_and_verify_server(server, client, results,
    "entry-to-be-updated", vse_key, "original-value")
  msg "Stopping client"
  client.crawler_stop
  client.indexer_stop
  delete_no_verify("server", server, results, vse_key)
  msg "Stopping server"
  server.crawler_stop
  server.indexer_stop
  msg "Starting client"
  client.crawler_start
  client.indexer_start
  enqueue_and_verify("client", client, results,
    "entry-to-be-updated", vse_key, "updated-value")
  msg "Starting server"
  server.crawler_start
  server.indexer_start
  msg "Checking audit log on server"
  check_audit_log_vse_key_deletes(server, results, "success", 2)
  check_and_purge_audit_log(server, results, "successful", 1)
  msg "Checking audit log on client"
  check_audit_log_vse_key_deletes(client, results, "success", 1)
  check_and_purge_audit_log(client, results, "successful", 2) # One for
    # url and one for vse-key delete

  check_all_collections_are_synchronized([server, client], results)
end

# Test 8.
def delete_of_nonexistent_data_is_reflected_on_both_hosts(server,
      client, results)
  print_test_header("Test 8. Delete of nonexistent data is reflected "\
    "on both hosts",
    "Delete by vse-key that has never been enqueued. "\
    "This attempt is reflected as an error on both server and client")

  vse_key="never-used-key"

  delete_no_verify("server", server, results, vse_key, expected_deletes=0)
  check_audit_log_vse_key_deletes(server, results, "error",
                       expected_deletes=1, sub=false)
  check_audit_log_vse_key_deletes(server, results, "success",
                       expected_deletes=0)
  check_and_purge_audit_log(server, results, "unsuccessful",
                       expected_entries=1)
  check_audit_log_vse_key_deletes(client, results, "error",
                       expected_deletes=1, sub=false)
  check_audit_log_vse_key_deletes(client, results, "success",
                       expected_deletes=0)
  check_and_purge_audit_log(client, results, "unsuccessful",
                       expected_entries=1)

  check_all_collections_are_synchronized([server, client], results)
end

# ----------------- Main ------------------ #

results = TestResults.new('Configuration consists of one server and one client.',
                          'Test various scenarios of deletes with vse-key. ',
                          'In every test all documents with the same vse-key ',
                          'should be deleted on server and on client')

results.need_system_report = false

SERVER_NAME = "repl-synch-1-s1"
CLIENT_NAME = "repl-synch-1-c1"
SERVER_PORT = "40411"

server, client = setup(results, SERVER_NAME, CLIENT_NAME, SERVER_PORT)

# Execute tests
value_enqueued_on_server_is_deleted(server, client, results)
values_enqueued_on_server_and_client_are_deleted(server, client, results)
value_enqueued_on_client_is_deleted(server, client, results)
value_deleted_on_client_does_not_affect_delete(server, client, results)
multiple_entries_with_selected_vse_key_are_deleted(server, client, results)
only_entries_with_selected_vse_key_are_deleted(server, client, results)
later_addition_on_client_is_not_deleted(server, client, results)
later_update_on_client_is_not_deleted(server, client, results)
delete_of_nonexistent_data_is_reflected_on_both_hosts(server,
      client, results)

msg "-----------------------"
results.cleanup_and_exit!
