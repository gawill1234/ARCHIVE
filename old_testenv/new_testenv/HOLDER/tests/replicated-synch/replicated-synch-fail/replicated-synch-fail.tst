#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'repl-synch-common'
require 'collection'
require 'host_wrappers'
require 'host_env'
require 'misc'
require 'thread_safe_test_results'
require 'url_hash'
require 'get_audit_log'
require 'allows_failures_enqueuer'
require 'parse_command_line_options'
require 'crawl_url_creator'
require 'setup_servers_and_clients'

SERVER1_NAME = "repl-synch-1-s1"
SERVER2_NAME = "repl-synch-1-s2"
CLIENT1_NAME = "repl-synch-1-c1"
CLIENT2_NAME = "repl-synch-1-c2"
SERVER1_PORT = "40411"
SERVER2_PORT = "50511"

results = TestResults.new('Set audit log to finished-or-replicated and ',
                          'begin enqueuing heavy traffic to each server. ',
                          'Shutdown server2 while enqueuing and make sure ',
                          'no new replicated entries appear on server1. ',
                          'Delete collection on server2 to cause a rebase ',
                          'and check that all nodes have the same index in ',
                          'the end.')

results = ThreadSafeTestResults.new(results)
results.need_system_report = false

msg "Reading host configurations"

options = parse_command_line_options

server1_c, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
server1_c2, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
server2_c, server2_addr = host_collection(SERVER2_NAME, options[:server2cfg])
server2_c2, server2_addr = host_collection(SERVER2_NAME, options[:server2cfg])
client1_c, client1_addr = host_collection(CLIENT1_NAME, options[:client1cfg])
client2_c, client2_addr = host_collection(CLIENT2_NAME, options[:client2cfg])

results.add(server1_c,
            "Host file for #{server1_addr} read and configured!",
            "Configuration file #{options[:server1cfg]} could not be read!")
results.add(server2_c,
            "Host file for #{server2_addr} read and configured!",
            "Configuration file #{options[:server2cfg]} could not be read!")
results.add(client1_c,
            "Host file for #{client1_addr} read and configured!",
            "Configuration file #{options[:client1cfg]} could not be read!")
results.add(client2_c,
            "Host file for #{client2_addr} read and configured!",
            "Configuration file #{options[:client2cfg]} could not be read!")

if (not server1_c or not server2_c or not client1_c or not client2_c)
  results.cleanup_and_exit!
end

results.associate(server1_c)
results.associate(server2_c)
results.associate(client1_c)
results.associate(client2_c)

setup_servers_and_clients(server1_c, server1_addr,
                          server2_c, server2_addr,
                          client1_c, client1_addr,
                          client2_c, client2_addr,
                          'finished-or-replicated')

server1_hash = UrlHash.new(SERVER1_NAME, results)
server2_hash = UrlHash.new(SERVER2_NAME, results)
client1_hash = UrlHash.new(CLIENT1_NAME, results)
client2_hash = UrlHash.new(CLIENT2_NAME, results)

s1_rep_count = 0
s1_fin_count = 0
s2_rep_count = 0
s2_fin_count = 0

# Start collections
msg "Starting collections..."

[server1_c, server2_c, client1_c, client2_c].each do |collection|
  collection.crawler_start
  collection.indexer_start
end

msg "Done."

# Begin heavy enqueue to both servers
s1_enq = AllowsFailuresEnqueuer.new(server1_c2, CrawlUrlCreator.new, results)
s2_enq = AllowsFailuresEnqueuer.new(server2_c2, CrawlUrlCreator.new, results)

s1_enq.begin_enqueue
s2_enq.begin_enqueue

# Let plenty of documents get enqueued
ENQUEUE_DOC_COUNT = 25
while (s1_enq.enqueued_documents < ENQUEUE_DOC_COUNT or s2_enq.enqueued_documents < ENQUEUE_DOC_COUNT)
  sleep 1
end

# Read, purge, and keep track of audit log entries so far
# Force getting a few replicated entries
while server1_hash.replicated_count == 0 or server2_hash.replicated_count == 0
  get_audit_log(server1_c, server1_hash, results)
  get_audit_log(server2_c, server2_hash, results)
end

s1_rep_count = server1_hash.replicated_count
s1_fin_count = server1_hash.finished_count
results.add(server1_hash.finished_count >= server1_hash.replicated_count,
            "Found #{server1_hash.finished_count} finished entries and #{server1_hash.replicated_count} replicated entries on #{server1_c.name}.",
            "Found #{server1_hash.finished_count} finished entries and #{server1_hash.replicated_count} replicated entries on #{server1_c.name}, expected more finished than replicated entries.")

results.add(server2_hash.finished_count >= server2_hash.replicated_count,
            "Found #{server2_hash.finished_count} finished entries and #{server2_hash.replicated_count} replicated entries on #{server2_c.name}.",
            "Found #{server2_hash.finished_count} finished entries and #{server2_hash.replicated_count} replicated entries on #{server2_c.name}, expected more finished than replicated entries.")

msg "Deleting #{server2_c.name}."
s2_enq.allow_failed_enqueues
s1_enq.stop_enqueue
s2_enq.stop_enqueue

msg "Wait for all entries to be replicated/finished on #{server2_c.name}."
while server2_hash.replicated_count != server2_hash.finished_count
  get_audit_log(server2_c, server2_hash, results)
  sleep 1
end

msg "Wait for all entries to be replicated/finished on #{server1_c.name}."
while server1_hash.replicated_count != server1_hash.finished_count
  get_audit_log(server1_c, server1_hash, results)
  sleep 1
end

s2_rep_count = server2_hash.replicated_count
s2_fin_count = server2_hash.finished_count

while ! server2_c.delete do
end

s1_enq.begin_enqueue
s2_enq.begin_enqueue

# Read server1's log, expect few replication complete entries
sleep 60
get_audit_log(server1_c, server1_hash, results)

results.add(server1_hash.finished_count > s1_fin_count,
            "Found more finished entries on #{server1_c.name}.")
s1_fin_count = server1_hash.finished_count
s1_rep_count = server1_hash.replicated_count

msg "Reread #{server1_c.name} log and expect no new replicated entries."
sleep 60
while (s1_fin_count == server1_hash.finished_count)
  get_audit_log(server1_c, server1_hash, results)
end

results.add(server1_hash.replicated_count == s1_rep_count,
            "Replicated entry count has not changed on #{server1_c.name}.",
            "Replicated entry count has changed on #{server1_c.name} from #{s1_rep_count} to #{server1_hash.replicated_count}.")

# Read client1 log, expect some finished entries that have not been replicated
end_of_wait = Time.now + 10*60
while (client1_hash.finished_count <= server1_hash.replicated_count and
       Time.now <= end_of_wait)
  sleep 1
  get_audit_log(client1_c, client1_hash, results)
  get_audit_log(server1_c, server1_hash, results)
end

c1_fin_count = client1_hash.finished_count
s1_rep_count = server1_hash.replicated_count
s1_fin_count = server1_hash.finished_count

num = 0 # Counter for all entries that are finished but not replicated
client1_hash.hash.each {|k,v|
  s1_val = server1_hash.hash[k]
  if s1_val == 'finished'
    num += 1
  end
}

results.add(num > 0,
            "Found #{num} entries on #{client1_c.name} that weren't replicated."
            )

msg "Recreating empty collection for #{server2_addr}"
server2_c.create
configure_audit_log(server2_c, 'finished-or-replicated')
configure_remote_client(server2_c, SERVER1_NAME, server1_addr + ":#{SERVER1_PORT}", server1_addr + ":#{SERVER1_PORT}")
configure_remote_common(server2_c)
configure_remote_server(server2_c, SERVER1_NAME + "\n" + CLIENT2_NAME, SERVER2_PORT, SERVER1_NAME)
server2_hash.clear

msg "Starting collection for #{server2_addr}"
server2_c.crawler_start
server2_c.indexer_start

def rebase_complete?(collection)
  return false unless collection.crawler_idle?

  crawler_stat = collection.crawler_status

  return ! (crawler_stat[:request_rebase] || crawler_stat[:receive_rebase])
end

# Wait until crawler is idle before expecting enqueues to not fail
while ! rebase_complete?(server2_c)
end
s2_enq.disallow_failed_enqueues

sleep 15
s1_enq.stop_enqueue
s2_enq.stop_enqueue

# Wait a maximum of 10 minutes for all the clients/servers to finish updating
done = false
end_of_wait = Time.now + 60*10

while not done and Time.now < end_of_wait
  sleep 1
  get_audit_log(server1_c, server1_hash, results)
  get_audit_log(server2_c, server2_hash, results)
  get_audit_log(client1_c, client1_hash, results)
  get_audit_log(client2_c, client2_hash, results)

  if (server1_hash.finished_count == server1_hash.replicated_count and
      client1_hash.finished_count == client2_hash.finished_count and
      server1_hash.finished_count == client1_hash.finished_count and
      server2_hash.replicated_count > 0)
    done = true
  end
end

# Check finished / replicated counts
expected_finished_count = server1_hash.finished_count

results.add_number_equals(expected_finished_count,
                          server1_hash.replicated_count,
                          "replicated document", :qualifier => "on #{SERVER1_NAME}")

results.add_number_equals(expected_finished_count,
                          client1_hash.finished_count,
                          "finished document", :qualifier => "on #{CLIENT1_NAME}")

results.add_number_equals(expected_finished_count,
                          client2_hash.finished_count,
                          "finished document", :qualifier => "on #{CLIENT2_NAME}")

results.add(server2_hash.replicated_count > 0,
            "#{SERVER2_NAME} replicated count is positive (#{server2_hash.replicated_count})")

# Check indexed documents
expected_indexed_doc_count = server1_c.index_n_docs

results.add_number_equals(expected_indexed_doc_count,
                          server2_c.index_n_docs,
                          "indexed document", :qualifier => "on #{SERVER2_NAME}")

results.add_number_equals(expected_indexed_doc_count,
                          client1_c.index_n_docs,
                          "indexed document", :qualifier => "on #{CLIENT1_NAME}")

results.add_number_equals(expected_indexed_doc_count,
                          client2_c.index_n_docs,
                          "indexed document", :qualifier => "on #{CLIENT2_NAME}")

results.cleanup_and_exit!



