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
require 'setup_servers_and_clients'
require 'parse_command_line_options'

# PRINT_AUDIT_LOG_IN_ANY_CASE: keep at "false", switch to "true"
#   when troubleshooting
PRINT_AUDIT_LOG_IN_ANY_CASE = false

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
  replicated_a = success_a.select {|e| e['replicated'] =~ /^replicated/}
  count = replicated_a.length

  results.add(count == expected,
              "Found #{count} entries in log.",
              "Found #{count} entries in log, expected #{expected}.")

  if audit_token and ! audit_token.empty?
    c.audit_log_purge(audit_token)
  end

  if (count != expected) or PRINT_AUDIT_LOG_IN_ANY_CASE
    msg "* Retrieved from audit log: *"
    msg "#{audit_log}"
    msg "* ------------------------- *"
  end

end

def wrap(urls)
  '<crawl-urls synchronization="indexed-no-sync" > %s </crawl-urls>' % urls
end

results = TestResults.new('Create four nodes: two servers that talk to each ',
                          'other and two clients.  Enqueue emails to each ',
                          'server and make sure the audit log properly shows ',
                          'each enqueue.  Enqueue a delete for each doc and ',
                          'ensure that a delete log entry exists.')
results.need_system_report = false

msg "Reading host configurations"

SERVER1_NAME = "repl-synch-1-s1"
SERVER2_NAME = "repl-synch-1-s2"
CLIENT1_NAME = "repl-synch-1-c1"
CLIENT2_NAME = "repl-synch-1-c2"
SERVER1_PORT = "40411"
SERVER2_PORT = "50511"

options = parse_command_line_options

server1_c, server1_addr = host_collection(SERVER1_NAME, options[:server1cfg])
server2_c, server2_addr = host_collection(SERVER2_NAME, options[:server2cfg])
client1_c, client1_addr = host_collection(CLIENT1_NAME, options[:client1cfg])
client2_c, client2_addr = host_collection(CLIENT2_NAME, options[:client2cfg])

results.add(server1_c,
            "Host file for server1 #{server1_addr} read and configured!",
            "Configuration file for server1 #{options[:server1cfg]} could not be read!")
results.add(server2_c,
            "Host file for server2 #{server2_addr} read and configured!",
            "Configuration file for server2 #{options[:server2cfg]} could not be read!")
results.add(client1_c,
            "Host file for client1 #{client1_addr} read and configured!",
            "Configuration file for client1 #{options[:client1cfg]} could not be read!")
results.add(client2_c,
            "Host file for client2 #{client2_addr} read and configured!",
            "Configuration file for client2 #{options[:client2cfg]} could not be read!")

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
                          'replicated')

# Start collections
msg "Starting collections..."

[server1_c, server2_c, client1_c, client2_c].each do |collection|
  collection.crawler_start
  collection.indexer_start
end

msg "Done."

msg "Enqueueing email to server1 #{server1_addr}."
COUNT = 2
EMAIL1 = "/testenv/test_data/havana/50076.eml"
EMAIL2 = "/testenv/test_data/havana/50077.eml"

crawl_url = '
<crawl-url url="http://lince/%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued" forced-vse-key="%s"><crawl-data encoding="utf-8" content-type="text/mail" ><![CDATA[%s]]></crawl-data></crawl-url>'

file = File.new(EMAIL1)
email1_data = ''
for line in file.readlines
  email1_data = email1_data + line
end
file.close

file = File.new(EMAIL2)
email2_data = ''
for line in file.readlines
  email2_data = email2_data + line
end
file.close

crawl_urls = crawl_url % [EMAIL1, key(0), email1_data] +
  crawl_url % [EMAIL2, key(1), email2_data]
to_enqueue = wrap(crawl_urls)

results.add(server1_c.enqueue_xml(to_enqueue),
            "Finished enqueuing email to server1 #{server1_addr}",
            "Failed to enqueue to server1 #{server1_addr}")

msg "Check that email appears in the audit log on only server nodes."

# Server 1
msg "Checking audit log on server1 #{server1_addr}."
check_audit_log(server1_c, results, "successful", COUNT)

# Server 2
msg "Checking audit log on server2 #{server2_addr}."
check_audit_log(server2_c, results, "successful", COUNT)

# Client 1
msg "Checking audit log on client1 #{client1_addr}."
check_audit_log(client1_c, results, "none", 0)

# Client 2
msg "Checking audit log on client2 #{client2_addr}."
check_audit_log(client2_c, results, "none", 0)

msg "Enqueue a few emails under an index-atomic to server2 #{server2_addr}."

atomic = '<index-atomic enqueue-id="mykey" >%s</index-atomic>'
crawl_urls = atomic % (
                       crawl_url %
                       [EMAIL1 + "-atomic", key(2), email1_data] +
                       crawl_url %
                       [EMAIL2 + "-atomic", key(3), email2_data])

to_enqueue = wrap(crawl_urls)
results.add(server2_c.enqueue_xml(to_enqueue),
            "Finished enqueuing email to server2 #{server2_addr}",
            "Failed to enqueue to server2 #{server2_addr}")

# Server 1
msg "Checking audit log on server1 #{server1_addr}."
check_audit_log(server1_c, results, "successful", 1)

# Server 2
msg "Checking audit log on server2 #{server2_addr}."
check_audit_log(server2_c, results, "successful", 1)

# Client 1
msg "Checking audit log on client1 #{client1_addr}."
check_audit_log(client1_c, results, "none", 0)

# Client 2
msg "Checking audit log on client2 #{client2_addr}."
check_audit_log(client2_c, results, "nonr", 0)

msg "Enqueuing a document for which conversion will fail to server1."

crawl_fail = '
<crawl-url url="http://lince/%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued" forced-vse-key="%s"><crawl-data encoding="utf-8" content-type="application/word" ><![CDATA[%s]]></crawl-data></crawl-url>'

to_enqueue = wrap(crawl_fail % [EMAIL1 + "-fail", key(4), email1_data])
results.add(! server1_c.enqueue_xml(to_enqueue),
            "Failed to enqueue unconvertable document to server1.",
            "Enqueue to server1 succeeded, should have return an error.")

msg "Make sure a failed entry exists on only server audit logs."

# Server 1
msg "Checking audit log on server1 #{server1_addr}."
check_audit_log(server1_c, results, "unsuccessful", 1)

# Server 2
msg "Checking audit log on server2 #{server2_addr}."
check_audit_log(server2_c, results, "unsuccessful", 1)

# Client 1
msg "Checking audit log on client1 #{client1_addr}."
check_audit_log(client1_c, results, "none", 0)

# Client 2
msg "Checking audit log on client2 #{client2_addr}."
check_audit_log(client2_c, results, "none", 0)

msg "Enqueue a vse-key delete to server2 #{server2_addr}."

crawl_delete = '<crawl-delete %s="%s" />'

msg "Deleting document http://lince/#{EMAIL1}."

# Need to find doc's vse-key which can only be done by a
# query as far as I know.
qr = server2_c.vapi.query_search(:sources => server2_c.name)
doc = qr.
  xpath("/query-results/list/document[@url='http://lince/#{EMAIL1}']")
key_to_delete = doc.first['vse-key']
crawl_delete_key = crawl_delete % ["vse-key", key_to_delete]
to_enqueue = wrap(crawl_delete_key)
results.add(server2_c.enqueue_xml(to_enqueue),
            "Deleted document with key #{key(0)} from server2.",
            "Failed to delete document with key #{key(0)} from server2.")

msg "Make sure a deleted entry exists on only server nodes."

# Server 1
msg "Checking audit log on server1 #{server1_addr}."
check_audit_log(server1_c, results, "successful", 2)

# Server 2
msg "Checking audit log on server2 #{server2_addr}."
check_audit_log(server2_c, results, "successful", 2)

# Client 1
msg "Checking audit log on client1 #{client1_addr}."
check_audit_log(client1_c, results, "none", 0)

# Client 2
msg "Checking audit log on client2 #{client2_addr}."
check_audit_log(client2_c, results, "none", 0)

msg "Deleting document http://#{EMAIL2}"

crawl_delete_url = crawl_delete % ["url", "http://#{EMAIL2}"]
to_enqueue = wrap(crawl_delete_url)
results.add(server1_c.enqueue_xml(to_enqueue),
            "Deleted document with url http://#{EMAIL2} from server1.",
            "Failed to delete document with url http://#{EMAIL2} from server1."
            )

# Server 1
msg "Checking audit log on server1 #{server1_addr}."
check_audit_log(server1_c, results, "successful", 1)

# Server 2
msg "Checking audit log on server2 #{server2_addr}."
check_audit_log(server2_c, results, "successful", 1)

# Client 1
msg "Checking audit log on client1 #{client1_addr}."
check_audit_log(client1_c, results, "none", 0)

# Client 2
msg "Checking audit log on client2 #{client2_addr}."
check_audit_log(client2_c, results, "none", 0)

# Cleanup
results.cleanup_and_exit!
