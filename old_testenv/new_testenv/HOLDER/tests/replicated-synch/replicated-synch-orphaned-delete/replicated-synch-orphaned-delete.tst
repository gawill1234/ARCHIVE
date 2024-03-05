#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'repl-synch-common'
require 'base64'
require 'collection'
require 'host_wrappers'
require 'host_env'
require 'misc'
require 'time'
require 'setup_server_and_client'
require 'parse_command_line_options'

def key(i)
  'key-%03d'%i
end

def check_audit_log(c, results, status, expected)
  # Wait as long as ten minutes (should this be longer?)
  end_of_wait = Time.now + 10*60
  audit_log_entries = nil
  audit_token = nil
  while ((! audit_log_entries or audit_log_entries.length != expected) and Time.now <= end_of_wait) do
    sleep 1
    audit_log = c.audit_log_retrieve
    audit_log_entries = audit_log.
      xpath('/audit-log-retrieve-response/audit-log-entry')
    audit_token = audit_log.
      xpath('/audit-log-retrieve-response/@token').first.to_s
  end

  success_a = audit_log_entries.select {|e| e['status'] =~ /^#{status}/}
  count = success_a.length

  results.add(count == expected,
              "Found #{count} entries in log.",
              "Found #{count} entries in log, expected #{expected}.")

  if audit_token and ! audit_token.empty?
    c.audit_log_purge(audit_token)
  end
end

def wrap(urls)
  '<crawl-urls synchronization="indexed-no-sync" > %s </crawl-urls>' % urls
end

results = TestResults.new('Create two nodes: one server and one client.',
                          'Enqueue a delete that does not correspond to',
                          'a URL to the server and ensure that it appears',
                          'in the client''s audit log')
results.need_system_report = false

msg "Reading host configurations"

SERVER1_NAME = "repl-synch-1-s1"
CLIENT1_NAME = "repl-synch-1-c1"
SERVER1_PORT = "40411"

options = parse_command_line_options

server1_c, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
client1_c, client1_addr = host_collection(CLIENT1_NAME, options[:client1cfg])

results.add(server1_c,
            "Host file for #{server1_addr} read and configured!",
            "Configuration file #{options[:server1cfg]} could not be read!")
results.add(client1_c,
            "Host file for #{client1_addr} read and configured!",
            "Configuration file #{options[:client1cfg]} could not be read!")

if (not server1_c or not client1_c)
  results.cleanup_and_exit!
end

results.associate(server1_c)
results.associate(client1_c)

setup_server_and_client(server1_c, server1_addr,
                         client1_c, client1_addr,
                         'finished')

# Start collections
msg "Starting collections..."

[server1_c, client1_c].each do |collection|
  collection.crawler_start
  collection.indexer_start
end

msg "Done."

EMAIL2="foo"

crawl_delete = '<crawl-delete %s="%s" />'

msg "Deleting document http://#{EMAIL2}"

crawl_delete_url = crawl_delete % ["url", "http://#{EMAIL2}"]
to_enqueue = wrap(crawl_delete_url)
results.add(server1_c.enqueue_xml(to_enqueue),
            "Deleted document with url http://#{EMAIL2}.",
            "Failed to delete document with url http://#{EMAIL2}."
            )

# Server 1
msg "Checking audit log on #{server1_addr}."
check_audit_log(server1_c, results, "successful", 1)

# Client 1
msg "Checking audit log on #{client1_addr}."
check_audit_log(client1_c, results, "successful", 1)

results.cleanup_and_exit!
