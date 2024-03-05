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
require 'ignore_all_failures_enqueuer'
require 'parse_command_line_options'
require 'crawl_url_creator'
require 'setup_servers_and_clients'
require 'service_killers'

SERVER1_NAME = "repl-synch-1-s1"
SERVER2_NAME = "repl-synch-1-s2"
CLIENT1_NAME = "repl-synch-1-c1"
CLIENT2_NAME = "repl-synch-1-c2"
SERVER1_PORT = "40411"
SERVER2_PORT = "50511"

results = TestResults.new('Enqueue heavy traffic to each server while ',
                          'randomly killing one of the indexer processes.',
                          'Expect all entries to appear across all nodes ',
                          'and no duplicate entries.')

results = ThreadSafeTestResults.new(results)
results.need_system_report = false

msg "Reading host configurations"

options = parse_command_line_options

# Set up host collections
server1_c, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
server1_c2, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
server1_c3, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
server2_c, server2_addr = host_collection(SERVER2_NAME, options[:server2cfg])
server2_c2, server2_addr = host_collection(SERVER2_NAME, options[:server2cfg])
server2_c3, server2_addr = host_collection(SERVER2_NAME, options[:server2cfg])
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
                          'finished')

server1_hash = UrlHash.new(SERVER1_NAME, results)
server2_hash = UrlHash.new(SERVER2_NAME, results)
client1_hash = UrlHash.new(CLIENT1_NAME, results)
client2_hash = UrlHash.new(CLIENT2_NAME, results)

# Start collections
msg "Starting collections..."

[server1_c, server2_c, client1_c, client2_c].each do |collection|
  collection.crawler_start
  collection.indexer_start
end

msg "Done."

# Begin heavy enqueue to both servers
s1_enq = IgnoreAllFailuresEnqueuer.new(server1_c2, CrawlUrlCreator.new)
s2_enq = IgnoreAllFailuresEnqueuer.new(server2_c2, CrawlUrlCreator.new)

s1_enq.begin_enqueue
s2_enq.begin_enqueue

# Start background killer threads
indexer_killer = IndexerKiller.new(server2_c3)
crawler_killer = CrawlerKiller.new(server1_c3)

indexer_killer.start
crawler_killer.start

# Read, purge, and keep track of audit log entries so far. Ensure there are
# no duplicate audit log entries.
ENQUEUE_DOC_COUNT = 500
while (s1_enq.enqueued_documents < ENQUEUE_DOC_COUNT and s2_enq.enqueued_documents < ENQUEUE_DOC_COUNT)
  sleep 30
  msg "Reading/purging audit logs."
  msg "Enqueued #{s1_enq.enqueued_documents} docs to #{SERVER1_NAME}."
  msg "Enqueued #{s2_enq.enqueued_documents} docs to #{SERVER2_NAME}."
  get_audit_log(server1_c, server1_hash, results)
  get_audit_log(server2_c, server2_hash, results)
  get_audit_log(client1_c, client1_hash, results)
  get_audit_log(client2_c, client2_hash, results)
end

indexer_killer.stop
crawler_killer.stop
s1_enq.stop_enqueue
s2_enq.stop_enqueue

# Ensure both crawlers are now running so that they can eventually distribute
# all updates.
server1_c.crawler_start
server2_c.crawler_start

# Wait at most five minutes for the audit log to settle down
end_of_wait = Time.now + 60*5
done = false

while not done and Time.now < end_of_wait
  sleep 10
  get_audit_log(server1_c, server1_hash, results)
  get_audit_log(server2_c, server2_hash, results)
  get_audit_log(client1_c, client1_hash, results)
  get_audit_log(client2_c, client2_hash, results)

  # Make sure all the different entry counts match.
  if (server1_hash.finished_count == server2_hash.finished_count and
      client1_hash.finished_count == client2_hash.finished_count and
      server1_hash.finished_count == client1_hash.finished_count and
      server1_hash.replicated_count == server2_hash.replicated_count and
      server2_hash.replicated_count == 0)
    done = true
  end
end

results.add(done,
            "Found equal number of finished and replicated entries on all nodes.",
            "Number of entries differs between nodes:
             #{server1_c.name}: #{server1_hash.finished_count} finished,  #{server1_hash.replicated_count} replicated
             #{server2_c.name}: #{server2_hash.finished_count} finished,  #{server2_hash.replicated_count} replicated
             #{client1_c.name}: #{client1_hash.finished_count} finished
             #{client2_c.name}: #{client2_hash.finished_count} finished.")


# Turn this check off for now
#results.add(server1_c.index_n_docs == server2_c.index_n_docs &&
#            server2_c.index_n_docs == client1_c.index_n_docs &&
#            client1_c.index_n_docs == client2_c.index_n_docs,
#            "Found #{server1_c.index_n_docs} docs on all nodes.",
#            "Number of indexed documents differ:
#             #{server1_c.name} has #{server1_c.index_n_docs} docs
#             #{server2_c.name} has #{server2_c.index_n_docs} docs
#             #{client1_c.name} has #{client1_c.index_n_docs} docs
#             #{client2_c.name} has #{client2_c.index_n_docs} docs.")

results.cleanup_and_exit!



