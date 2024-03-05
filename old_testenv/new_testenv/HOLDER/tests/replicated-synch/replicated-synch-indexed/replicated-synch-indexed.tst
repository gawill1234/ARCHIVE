#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'repl-synch-common'
require 'audit_log_helper'
require 'collection'
require 'misc'


# ----------------- Configuration ------------------

def setup(results, server_name, client_name, port, remove_light_crawler=false)
  msg "Setting up server and client"

  server, client = setup_server_and_client(server_name, client_name,
                     port, "finished")

  results.associate(server)
  results.associate(client)

  if remove_light_crawler
    remove_light_crawler(server)
    remove_light_crawler(client)
  end

  [server, client]
end

# ----------------------- Enqueue details ------------------------

def wrap(urls)
  '<crawl-urls> %s </crawl-urls>' % urls
end

def enqueue_and_verify(host, results, url, vse_key, url_data)
  crawl_url = '<crawl-url url="http://%s" status="complete" synchronization="indexed" enqueue-type="reenqueued" vse-key="%s" vse-key-normalized="vse-key-normalized"><crawl-data>%s</crawl-data></crawl-url>'

  results.add(host.enqueue_xml(wrap(crawl_url % [url, vse_key, url_data])),
            "Finished enqueuing #{url} to #{host.name}",
            "Failed to enqueue #{url} to #{host.name}")

  check_and_purge_audit_log(host, results, "successful", 1)
end

# ---------------- Tests ----------------- #

def print_test_header(title, description)
  puts "---------------------------"
  msg "#{title}:"
  puts "         #{description}"
end

def let_client_get_updates(client, results, expected_number_of_updates)
  client.crawler_start
  client.indexer_start
  check_and_purge_audit_log(client, results, "successful",
    expected_number_of_updates)
  client.stop
end

# Bug 29355, comment #8
def bug_29355_comment_8(server, client, results)
  print_test_header("Bug 29355",
    "Specific scenario that used to be likely "\
    "to cause client to hang.")

  server.crawler_start
  server.indexer_start
  enqueue_and_verify(server, results, url="url-to-keep",
    vse_key="url-to-keep-vse-key", url_data="Data to keep")
  let_client_get_updates(client, results, 1)

  enqueue_and_verify(server, results, url="url-to-delete",
    vse_key="url-to-delete-vse-key", url_data="Url to delete")
  let_client_get_updates(client, results, 1)

  results.add(server.enqueue_xml(
    '<crawl-delete dummy-attribute="2" synchronization="indexed" '\
    'vse-key="url-to-delete-vse-key" />'),
      "Deleted document with vse-key #{vse_key} from server.",
      "Failed to delete document with vse-key #{vse_key} from server."
  )
  # Note: Stan confirmed that dummy-attribute="2" was significant for the
  #   likelyhood of the issue to occur
  client.crawler_start
  client.indexer_start
  check_and_purge_audit_log(client, results, "successful", 2)

  check_all_collections_are_synchronized([server, client], results)

end

# ----------------- Main ------------------ #

results = TestResults.new('In this set of tests synchronization on enqueues ',
                          'is "indexed".')

results.need_system_report = false

SERVER_NAME = "repl-synch-1-s1"
CLIENT_NAME = "repl-synch-1-c1"
SERVER_PORT = "40411"

puts "------- Setup server and client with light crawler and run the test -"\
  "-------"

server, client = setup(results, SERVER_NAME, CLIENT_NAME, SERVER_PORT)
bug_29355_comment_8(server, client, results)

puts "------- Setup server and client without light crawler and run "\
  "the test --------"

server, client = setup(results, SERVER_NAME, CLIENT_NAME, SERVER_PORT,
  remove_light_crawler=true)
bug_29355_comment_8(server, client, results)

msg "-----------------------"
results.cleanup_and_exit!

