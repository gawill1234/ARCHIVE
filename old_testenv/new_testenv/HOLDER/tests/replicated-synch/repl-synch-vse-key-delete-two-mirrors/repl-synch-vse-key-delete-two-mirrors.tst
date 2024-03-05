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

def setup(results, server1_name, server2_name, port1, port2)
  msg "Setting up two mirror servers"

  server1, server2 = setup_two_mirrors(server1_name, server2_name,
                     port1, port2, "finished")

  results.associate(server1)
  results.associate(server2)

  if REMOVE_LIGHT_CRAWLER
    remove_light_crawler(server1)
    remove_light_crawler(server2)
  end

  msg "Starting collections..."
  [server1, server2].each do |collection|
    collection.crawler_start
    collection.indexer_start
  end
  msg "Done starting collections."
  [server1, server2]
end

# ----------------------- Enqueue details ------------------------

def wrap(urls)
  '<crawl-urls synchronization="indexed-no-sync" > %s </crawl-urls>' % urls
end

def enqueue_and_verify(host, results, url, vse_key, url_data)
  crawl_url = '<crawl-url url="http://%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued" forced-vse-key="%s" forced-vse-key-normalized="forced-vse-key-normalized"><crawl-data encoding="xml" content-type="application/vxml"><document><content name="field1">%s</content></document></crawl-data></crawl-url>'

  results.add(host.enqueue_xml(wrap(crawl_url % [url, vse_key, url_data])),
            "Finished enqueuing #{url} to #{host.name}",
            "Failed to enqueue #{url} to #{host.name}")

  check_and_purge_audit_log(host, results, "successful", 1)
end

def enqueue_and_verify_server(server, client, results, url, vse_key, url_data)
  enqueue_and_verify(server, results, url, vse_key, url_data)
  # Checking audit log on client for replicated entry.
  check_and_purge_audit_log(client, results, "successful", 1)
end

# Verify vs no-verify stands for checking audit log. We still check
# return value, even with no-verify
def delete_no_verify(host, results, vse_key, expected_deletes=1)
  crawl_delete = '<crawl-delete %s="%s" />'
  delete_status = host.enqueue_xml(wrap(
                         crawl_delete % ["vse-key", "#{vse_key}"]))
  if expected_deletes > 0
    results.add(delete_status,
      "Deleted document with vse-key #{vse_key} from #{host.name}.",
      "Failed to delete document with vse-key #{vse_key} from #{host.name}."
    )
  else
    results.add(!delete_status,
      "As expected, failed to delete document with vse-key #{vse_key} from #{host.name}.",
      "Deleted document with vse-key #{vse_key} from #{host.name}. - shouldn't be able to"
    )
  end
end

def delete_and_verify(host, results, vse_key, expected_deletes,
                        expected_entries)
  delete_no_verify(host, results, vse_key, expected_deletes)
  check_audit_log_vse_key_deletes(host, results, "success", expected_deletes)
  check_and_purge_audit_log(host, results, "successful", expected_entries)
end

def delete_and_verify_server(server, client, results, vse_key,
      expected_deletes_server, expected_entries_server,
      expected_deletes_client, expected_entries_client)
  delete_and_verify(server, results, vse_key,
                    expected_deletes_server, expected_entries_server)
  check_audit_log_vse_key_deletes(client, results, "success",
                                  expected_deletes_client)
  check_and_purge_audit_log(client, results, "successful",
                            expected_entries_client)
end

def stop(host)
  msg "Stopping #{host.name}"
  host.stop
end

def start(host)
  msg "Starting #{host.name}"
  host.crawler_start
  host.indexer_start
end

# ---------------- Tests ----------------- #

def print_test_header(title, description)
  puts "---------------------------"
  msg "#{title}:"
  puts "         #{description}"
end


# Test 0.
def value_enqueued_on_one_server_is_deleted(server1, server2, results)
  print_test_header("Test 0. Base case - enqueue on server1 only",
    "Value enqueued on server1, replicated on server2; "\
    "no extra entries on server2. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from server1 and server2")

  vse_key="server1-only-key"

  enqueue_and_verify_server(server1, server2, results, "server1-only",
    vse_key, "server1-only")

  delete_and_verify_server(server1, server2, results, vse_key,
    expected_deletes_server=1,
    expected_entries_server=1,
    expected_deletes_client=1,
    expected_entries_client=2 # One for url delete and one for vse-key delete
  )
  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 1.
def values_enqueued_on_either_server_are_deleted(server1, server2, results)
  print_test_header("Test 1. Enqueue on both servers",
    "Value enqueued on server1, replicated on server2; another value "\
    "enqueued on server2, replicated on server1. "\
    "Delete by vse-key enqueued on server1 should delete all entries "\
    "from both servers")

  vse_key="both-servers-key"

  enqueue_and_verify_server(server1, server2, results, "url-on-server1",
    vse_key, "url-on-server1")
  enqueue_and_verify_server(server2, server1, results, "url-on-server2",
    vse_key, "url-on-server2")

  delete_and_verify_server(server1, server2, results, vse_key,
    expected_deletes_server=2,
    expected_entries_server=1,
    expected_deletes_client=2, # One for each url
    expected_entries_client=2  # One for urls delete and one for vse-key delete
  )
  check_all_collections_are_synchronized([server1, server2], results)
end


# Test 2.
def value_enqueued_on_other_server_is_deleted(server1, server2, results)
  print_test_header("Test 2. Delete on server with replicated entry",
    "Nothing enqueued on server1; a value enqueued on server2, "\
    "replicated on server1. "\
    "Delete by vse-key enqueued on server1 should delete all entries "\
    "from both servers")

  vse_key="other-server-key"

  enqueue_and_verify_server(server2, server1, results, "other-server-key",
    vse_key, "other-server-key")

  delete_and_verify_server(server1, server2, results, vse_key,
    expected_deletes_server=1,
    expected_entries_server=1,
    expected_deletes_client=1,
    expected_entries_client=2
  )
  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 3a.
def delete_of_previously_deleted_data_is_reflected_on_both_servers(server1,
      server2, results)
  print_test_header("Test 3a. Delete of previously deleted data is reflected "\
    "on both servers",
    "A value is enqueued on server1, replicated on server2, "\
    "then deleted on server2 via vse-key delete. "\
    "Delete by vse-key enqueued on server1 is reflected as an error "\
    "on both servers")

  vse_key="replicated-entry-pre-deleted-key"

  enqueue_and_verify_server(server1, server2, results,
    "replicated-entry-to-be-pre-deleted", vse_key,
    "replicated-entry-to-be-pre-deleted")
  delete_and_verify_server(server2, server1, results, vse_key,
    expected_deletes_server=1,
    expected_entries_server=1,
    expected_deletes_client=1,
    expected_entries_client=2
  )
  # When we send delete for already-deleted entries, it is detected
  # that there is no such an entry in the collection,
  # so the response is state=error, siphoned=nonexistent.
  # This applies to the configuration with and without light crawler
  # (see Bugzilla bug 29391 for discussion)
  delete_no_verify(server1, results, vse_key, expected_deletes=0)
  check_audit_log_vse_key_deletes(server1, results, "error",
                       expected_deletes=1, sub=false)
  check_audit_log_vse_key_deletes(server1, results, "success",
                       expected_deletes=0)
  check_and_purge_audit_log(server1, results, "unsuccessful",
                       expected_entries=1)
  check_audit_log_vse_key_deletes(server2, results, "error",
                       expected_deletes=1, sub=false)
  check_audit_log_vse_key_deletes(server2, results, "success",
                       expected_deletes=0)
  check_and_purge_audit_log(server2, results, "unsuccessful",
                       expected_entries=1)

  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 3b.
def delete_of_nonexistent_data_is_reflected_on_both_servers(server1,
      server2, results)
  print_test_header("Test 3b. Delete of nonexistent data is reflected "\
    " on both servers",
    "Delete by vse-key that has never been enqueued. "\
    "This attempt is reflected as an error on both servers")

  vse_key="never-used-key"

  delete_no_verify(server1, results, vse_key, expected_deletes=0)
  check_audit_log_vse_key_deletes(server1, results, "error",
                       expected_deletes=1, sub=false)
  check_audit_log_vse_key_deletes(server1, results, "success",
                       expected_deletes=0)
  check_and_purge_audit_log(server1, results, "unsuccessful",
                       expected_entries=1)
  check_audit_log_vse_key_deletes(server2, results, "error",
                       expected_deletes=1, sub=false)
  check_audit_log_vse_key_deletes(server2, results, "success",
                       expected_deletes=0)
  check_and_purge_audit_log(server2, results, "unsuccessful",
                       expected_entries=1)

  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 4.
def multiple_entries_with_selected_vse_key_are_deleted(server1,
      server2, results)
  print_test_header("Test 4. Higher number of entries",
    "9 urls with the same vse-key are enqueued on server1, replicated "\
    "on server2; 5 more urls enqueued on server2, replicated on server1. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "from both server.")

  vse_key="more-entries-key"

  (1..9).each do |j|
  enqueue_and_verify_server(server1, server2, results,
    "more-entries-group-#{j}", vse_key, "more-entries-group-#{j}")
  end
  (10..14).each do |j|
  enqueue_and_verify_server(server2, server1, results,
    "another-set-#{j}", vse_key, "another-set-#{j}")
  end

  delete_and_verify_server(server1, server2, results, vse_key,
    expected_deletes_server=14,
    expected_entries_server=1,
    expected_deletes_client=14,
    expected_entries_client=2 # One for urls delete and one for vse-key delete
  )
  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 5.
def only_entries_with_selected_vse_key_are_deleted(server1, server2, results)
  print_test_header("Test 5. With other data on both servers",
    "Data added, then 2 urls with the same vse-key are enqueued on server1, "\
    "replicated on server2; 3 urls enqueued on server2, replicated on "\
    "server1; more data added. "\
    "Delete by vse-key enqueued on server should delete all entries "\
    "with correct vse-key and leave the rest.")

  # First, adding ballast
  vse_key="ballast-before-key"

  (15..16).each do |j|
    enqueue_and_verify_server(server1, server2, results,
      "ballast-before-on-server-#{j}", vse_key, "ballast-before-on-server-#{j}")
  end
  (17..18).each do |j|
    enqueue_and_verify_server(server2, server1, results,
      "ballast-before-on-client-#{j}", vse_key, "ballast-before-on-client-#{j}")
  end

  # Now adding urls under test
  target_vse_key="target-key"

  (19..20).each do |j|
    enqueue_and_verify_server(server1, server2, results,
      "target-url-on-server-#{j}", target_vse_key, "target-url-on-server-#{j}")
  end
  (21..23).each do |j|
    enqueue_and_verify_server(server2, server1, results,
      "target-url-on-client-#{j}", target_vse_key, "target-url-on-client-#{j}")
  end

  # And now more ballast
  vse_key="data-after-key"

  (24..25).each do |j|
    enqueue_and_verify_server(server1, server2, results,
      "data-after-on-server-#{j}", vse_key, "data-after-on-server-#{j}")
  end
  (26..27).each do |j|
    enqueue_and_verify_server(server2, server1, results,
      "data-after-on-client-#{j}", vse_key, "data-after-on-client-#{j}")
  end

  # And finally delete
  delete_and_verify_server(server1, server2, results, target_vse_key,
    expected_deletes_server=5,
    expected_entries_server=1,
    expected_deletes_client=5,
    expected_entries_client=2 # One for urls and one for vse-key delete
  )

  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 6.
def later_addition_on_client_is_not_deleted(server1, server2, results)
  print_test_header("Test 6. Later addition on mirror is not deleted",
    "Entries that were added on the server2"\
    "after vse-key delete was processed on the server1, "\
    "are not deleted.")

  vse_key="later-addition-key"

  enqueue_and_verify_server(server1, server2, results,
    "first-entry-on-server1", vse_key, "first-entry-on-server1")
  enqueue_and_verify_server(server1, server2, results,
    "second-entry-on-server2", vse_key, "second-entry-on-server")
  stop(server2)
  delete_no_verify(server1, results, vse_key)
  stop(server1)
  start(server2)
  enqueue_and_verify(server2, results, "later-addition-on-server2",
    vse_key, "later-addition-on-server2")
  start(server1)
  msg "Checking audit log on server1"
  # Expect 2 delete sub-entries: one for first-entry-on-server and
  # one for second-entry-on-server
  check_audit_log_vse_key_deletes(server1, results, "success", 2)
  # Expect 2 entries: one for deletes and one for replication of
  # later-addition-on-client
  check_and_purge_audit_log(server1, results, "successful", 2)
  msg "Checking audit log on server2"
  # Expect 2 delete sub-entries: one for first-entry-on-server and
  # one for second-entry-on-server
  check_audit_log_vse_key_deletes(server2, results, "success", 2)
  # Expect 2 entries: one for urls-delete and one for vse-key-delete
  check_and_purge_audit_log(server2, results, "successful", 2)
  # At this point we also may want to check that later-addition-on-client
  # is there on both serveres

  check_all_collections_are_synchronized([server1, server2], results)
end

# Test 7.
def later_update_on_client_is_not_deleted(server1, server2, results)
  print_test_header("Test 7. Later update on mirror is not deleted",
    "Entries that were updated on the server2 "\
    "after vse-key delete was processed on the server1, "\
    "are not deleted.")

  vse_key="later-update-key"

  enqueue_and_verify_server(server1, server2, results,
    "unchanged-entry-on-server1", vse_key, "unchanged-entry-on-server1")
  enqueue_and_verify_server(server1, server2, results,
    "entry-to-be-updated", vse_key, "original-value")
  stop(server2)
  delete_no_verify(server1, results, vse_key)
  stop(server1)
  start(server2)
  enqueue_and_verify(server2, results,
    "entry-to-be-updated", vse_key, "updated-value")
  start(server1)
  msg "Checking audit log on server1"
  check_audit_log_vse_key_deletes(server1, results, "success", 2)
  check_and_purge_audit_log(server1, results, "successful", 2)
  msg "Checking audit log on server2"
  check_audit_log_vse_key_deletes(server2, results, "success", 1)
  check_and_purge_audit_log(server2, results, "successful", 2) # One for
    # url and one for vse-key delete
  # Bug 29367 causes failure in the  last two checks: 0 and 1 instead of
  # 1 and 2.
  check_all_collections_are_synchronized([server1, server2], results)
end

# ----------------- Main ------------------ #

results = TestResults.new('Configuration consists of two mirror servers ',
                          'getting updates from each other. ',
                          'Test various scenarios of deletes with vse-key. ')

results.need_system_report = false

SERVER1_NAME = "repl-synch-1-s1"
SERVER2_NAME = "repl-synch-1-s2"
SERVER1_PORT = "40415"
SERVER2_PORT = "40416"

server1, server2 = setup(results, SERVER1_NAME, SERVER2_NAME, SERVER1_PORT,
                     SERVER2_PORT)

# Execute tests
value_enqueued_on_one_server_is_deleted(server1, server2, results)
values_enqueued_on_either_server_are_deleted(server1, server2, results)
value_enqueued_on_other_server_is_deleted(server1, server2, results)
delete_of_previously_deleted_data_is_reflected_on_both_servers(server1,
  server2, results)
delete_of_nonexistent_data_is_reflected_on_both_servers(server1,
  server2, results)
multiple_entries_with_selected_vse_key_are_deleted(server1, server2, results)
only_entries_with_selected_vse_key_are_deleted(server1, server2, results)
later_addition_on_client_is_not_deleted(server1, server2, results)
later_update_on_client_is_not_deleted(server1, server2, results)

msg "-----------------------"
results.cleanup_and_exit!
