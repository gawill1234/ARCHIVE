#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'
$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'repl-synch-common'
require 'host_wrappers'
require 'misc'
require 'setup_three'
require 'parse_command_line_options'
require 'audit_log_helper'

# Parameters for testing additional configurations when necessary:

# REMOVE_LIGHT_CRAWLER: keep at "false", unless need to test
#   without light crawler
REMOVE_LIGHT_CRAWLER = false
# ADD_CALLBACK_CONFIGURATION : keep at "false", unless testing
#   this special configuration
ADD_CALLBACK_CONFIGURATION = false

def setup(results, server1_name, server2_name, client_name, port1, port2)
  msg "Setting up servers and client"

  options = parse_command_line_options

  server1_c, server1_addr = host_collection(server1_name, options[:server1cfg])
  server2_c, server2_addr = host_collection(server2_name, options[:server2cfg])
  client_c, client_addr = host_collection(client_name, options[:client1cfg])

  results.add(server1_c,
            "Host file for server #{server1_addr} read and configured!",
            "Configuration file for server #{options[:server1cfg]} could not be read!")

  results.add(server2_c,
            "Host file for #{server2_addr} read and configured!",
            "Configuration file #{options[:server2cfg]} could not be read!")

  results.add(client_c,
            "Host file for client #{client_addr} read and configured!",
            "Configuration file for client #{options[:client1cfg]} could not be read!")

  if (!server1_c || !server2_c || !client_c)
    results.cleanup_and_exit!
  end

  results.associate(server1_c)
  results.associate(server2_c)
  results.associate(client_c)

  setup_three(server1_c, server1_addr,
              server2_c, server2_addr,
              client_c, client_addr,
              port1, port2, 'finished')

  if REMOVE_LIGHT_CRAWLER
    remove_light_crawler(server1_c)
    remove_light_crawler(server2_c)
    remove_light_crawler(client_c)
  end

  if ADD_CALLBACK_CONFIGURATION
     configure_remote_server(client_c, "dummy", 9090)
  end

  msg "Starting collections..."
  [server1_c, server2_c, client_c].each do |collection|
    collection.crawler_start
    collection.indexer_start
  end
  msg "Done starting collections."
  [server1_c, server2_c, client_c]
end

def wrap(urls)
  '<crawl-urls synchronization="indexed-no-sync" > %s </crawl-urls>' % urls
end

def enqueue_multiple(host, results, url, url_data)
  crawl_url = '<crawl-url url="http://%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued"><crawl-data encoding="xml" content-type="application/vxml"><document><content name="field1">%s</content></document></crawl-data></crawl-url>'
  msg "Enqueueing #{url}s with #{url_data}s to #{host.name}."

  results.add(host.enqueue_xml(
    wrap( (crawl_url % [url, url_data]) +
          (crawl_url % ["xx#{url}", "xx#{url_data}"]) +
          (crawl_url % ["yy#{url}", "yy#{url_data}"]) +
          (crawl_url % ["zz#{url}", "zz#{url_data}"]) )),
            "Finished enqueuing #{url}s to #{host.name}",
            "Failed to enqueue #{url}s to #{host.name}")
end

def enqueue_no_verify(host, results, url, url_data)
  crawl_url = '<crawl-url url="http://%s" status="complete" synchronization="indexed-no-sync" enqueue-type="reenqueued"><crawl-data encoding="xml" content-type="application/vxml"><document><content name="field1">%s</content></document></crawl-data></crawl-url>'
  msg "Enqueueing #{url} with #{url_data} to #{host.name}."

  results.add(host.enqueue_xml(wrap(crawl_url % [url, url_data])),
            "Finished enqueuing #{url} to #{host.name}",
            "Failed to enqueue #{url} to #{host.name}")
end

def enqueue_and_verify(host, results, url, url_data)
  enqueue_no_verify(host, results, url, url_data)
  msg "Checking audit log on #{host.name}."
  check_and_purge_audit_log(host, results, "successful", 1)
end

def enqueue_and_verify_server(server, client, results, url, url_data)
  enqueue_and_verify(server, results, url, url_data)
  msg "Checking audit log on #{client.name} for replicated entry."
  check_and_purge_audit_log(client, results, "successful", 1)
end

def delete_no_verify(host, results, url)
  crawl_url = '<crawl-delete url="http://%s" />'
  msg "Deleting url #{url} from #{host.name}."

  results.add(host.enqueue_xml(wrap(crawl_url % [url])),
            "Finished deleting url #{url} from #{host.name}",
            "Failed to delete url #{url} from #{host.name}")
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

def verify_value(results, host, url, expected_value)
  qr = host.vapi.query_search(:sources => host.name, :num => 60)
  content = qr.
    xpath("/query-results/list/document[@url='http://#{url}']/"\
        "content[@name='field1']/text()")
  results.add(content.to_s == expected_value,
              "Found expected value #{expected_value} for "\
              "url #{url} on #{host.name}",
              "Value for url #{url} on #{host.name} is #{content}, "\
              "expected #{expected_value}.\n*** Full search results ***\n"\
              "#{qr}\n*** End of search results ***")
end

def print_test_header(title, description)
  puts "---------------------------"
  msg "#{title}:"
  puts "         #{description}"
end

# Test 0
def check_configuration(server1_c, server2_c, client_c, results)
  print_test_header("Check configuration",
     "A value enqueued on server1, replicated on client; "\
     " Another value enqueued on server2, replicated on client")
  enqueue_and_verify_server(server1_c, client_c, results, "CheckConf-server1",
  "CheckConf-server1")
  enqueue_and_verify_server(server2_c, client_c, results, "CheckConf-server2",
  "CheckConf-server2")
end

# Test 1
def earlier_update_does_not_override_later_update(server1_c,
      server2_c, client_c, results)
  print_test_header("Basic test for competing servers",
    "If earlier update reaches client later, it shouldn't "\
    "overwrite current value")
  stop(client_c)
  enqueue_no_verify(server1_c, results, "Earlier-no-override",
    "Earlier-update")
  stop(server1_c)
  sleep 1 # To ensure difference in timestamps
  enqueue_no_verify(server2_c, results, "Earlier-no-override",
    "Later-update")
  start(client_c)
  check_and_purge_audit_log(client_c, results, "successful", 1)
  start(server1_c)
  check_and_purge_audit_log(client_c, results, "unsuccessful", 1)
  verify_value(results, client_c, "Earlier-no-override", "Later-update")
  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# Test 2
def later_update_overrides_earlier_update(server1_c, server2_c, client_c, results)
  print_test_header("Regression test for competing servers",
    "Later update should overwrite current value on client")
  stop(client_c)

  enqueue_and_verify(server1_c, results, "Later-wins", "Earlier-value")
  sleep 1 # To ensure difference in timestamps
  enqueue_and_verify(server2_c, results, "Later-wins", "Later-value")
  stop(server2_c)

  start(client_c)
  check_and_purge_audit_log(client_c, results, "successful", 1)
  verify_value(results, client_c, "Later-wins", "Earlier-value")

  start(server2_c)
  check_and_purge_audit_log(client_c, results, "successful", 1)
  verify_value(results, client_c, "Later-wins", "Later-value")
  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# Test 3
def continuous_conflicts_servers(server1_c, server2_c, client_c, results)
  print_test_header("Sustainability test for competing servers", "")
  # Details:
  # Run a counter and enqueue randomly-selected url with a value of the
  # counter to a randomly-selected server. Keep track of the highest value
  # for each url. After synchronization completes, each url on client
  # should have the highest value.

  max_count = 100
  max_url = 5
  max_value = Array.new(max_url-1,0)

  # Perform enqueues
  max_count.times do |i| # for i=0 to max_count-1
    which_url=rand(max_url)
    max_value[which_url]=i
    target_host = [server1_c, server2_c].sample
    enqueue_no_verify(target_host, results,
      "Conflicts-servers-#{which_url.to_s}", i.to_s)
    # Without "sleep 1" here test sometimes fails on one of the urls, if two
    # consequent updates were performed for the same url to different
    # collections.
    # Stan believes that this test has "rights" to fail without "sleep 1",
    # but failure with "sleep 1" would indicate a real problem.
    sleep 1
  end

  check_and_purge_audit_log(client_c, results, "successful", 100)

  # Verify that client has expected (highest enqueued) value for each url
  max_url.times do |y| # for y=0 to max_url-1
    verify_value(results, client_c, "Conflicts-servers-#{y.to_s}",
      max_value[y].to_s)
  end
  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# Test 4
def continuous_conflicts_all_hosts(server1_c, server2_c, client_c, results)
  print_test_header("Sustainability test for competing servers, includes"\
    " enqueues to client", "")
  # Like continuous_conflicts_servers, but some enqueues go to client.

  max_count = 100
  max_url = 5
  max_value = Array.new(max_url-1,0)

  # Perform enqueues
  max_count.times do |i| # for i=0 to max_count-1
    which_url=rand(max_url)
    max_value[which_url]=i
    target_host = [server1_c, server2_c, client_c].sample
    enqueue_no_verify(target_host, results,
      "Conflicts-all-#{which_url.to_s}", i.to_s)
    # Without "sleep 1" here test sometimes fails on one of the urls, if two
    # consequent updates were performed for the same url to different
    # collections.
    # Stan believes that this test has "rights" to fail without "sleep 1",
    # but failure with "sleep 1" would indicate a real problem.
    sleep 1
  end

  check_and_purge_audit_log(client_c, results, "successful", 100)

  # Verify that client has expected (highest enqueued) value for each url
  max_url.times do |y| # for y=0 to max_url-1
    verify_value(results, client_c, "Conflicts-all-#{y.to_s}",
      max_value[y].to_s)
  end
  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# Helper for vertices_reuse test
def check_vertex_reuse(host, results, audit_log=nil)
  if (! audit_log)
    audit_log = host.audit_log_retrieve
  end
  min_vertex, max_vertex = get_vertex_range_from_audit_log(audit_log)
  if (min_vertex && max_vertex)
    results.add((max_vertex - min_vertex) <=18,
      "Min value of vertex is #{min_vertex}, max value of vertex is #{max_vertex}, indicating vertex reuse on #{host.name}",
      "Min value of vertex is #{min_vertex}, max value of vertex is #{max_vertex}, indicating no vertex reuse on #{host.name}")
  else
    results.add_failure("No entries in audit log to check for vertex reuse")
  end
end

# Test 5
def vertices_reuse(server1_c, server2_c, client_c, results)
  print_test_header("Vertices reuse",
    "With light crawler, when both servers and client stay connected, "\
    "an internal table gets regularly purged, and freed vertices "\
    "are made available for reuse. So, 20 different urls in this test "\
    "under 'slow enough' conditions keep reusing the same vertices. "\
    "Without light crawler, vertices are not reused.")

  # Note 1: Sleep time for this test was picked experimentally,
  #   based on observations when running against a local windows machine.
  # Without any sleep time audit log includes 20 vertices (0-19), so it is
  #   not suitable for this test.
  # With sleep 10 - 7 vertices - this makes vertex reuse most visible.
  # With sleep 20 - 4 vertices.

  # Note 2: The test uses four urls per enqueue. This is essential, because
  # in tests 3 and 4, where there is only one url per enqueue, all vertices
  # are usually "0", and we want to see more than one value in this test.

  sleep_time_between_enqueues = 10

  max_count = 50
  max_url = 5
  max_value = Array.new(max_url-1,0)

  # Perform enqueues
  max_count.times do |i|
    which_url=rand(max_url)
    max_value[which_url]=i
    target_host = [server1_c, server2_c, client_c].sample
    enqueue_multiple(target_host, results,
      "Reuse-#{which_url.to_s}", i.to_s)
    sleep sleep_time_between_enqueues
  end

  audit_log_on_client =
    check_and_purge_audit_log(client_c, results, "successful", 200)

  # Verify that client has expected value for each url
  max_url.times do |y|
    verify_value(results, client_c, "Reuse-#{y.to_s}",
      max_value[y].to_s)
  end

  if REMOVE_LIGHT_CRAWLER
    # then this test is not applicable, so we loosely check the opposite
    # condition: vertice shouldn't be reused on client, so we should expect
    # at least 20 for the max value
    min_vertex, max_vertex =
      get_vertex_range_from_audit_log(audit_log_on_client)
    if (max_vertex)
      results.add(max_vertex >= 19,
        "Min value of vertex is #{min_vertex}, max value of vertex is "\
        "#{max_vertex}, indicating no vertex reuse on client",
        "Min value of vertex is #{min_vertex}, max value of vertex is "\
        "#{max_vertex}, indicating vertex reuse on client")
    else
      results.add_failure("No entries in audit log to check for vertex reuse")
    end
  else
    # actual test
    check_vertex_reuse(server1_c, results)
    check_vertex_reuse(server2_c, results)
    check_vertex_reuse(client_c, results, audit_log_on_client)
    # Note: "Normal" range is between 0 and some number less than 19 for vertex reuse, and 19 for "no vertex reuse"
    # If it is different, it is different in unexpected way.
  end

  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# Test 6
def no_vertices_reuse_while_server_offline(server1_c, server2_c,
      client_c, results)
  print_test_header("No vertices reuse while server is offline",
    "There should be no vertices reuse if one of the servers "\
    "is offline. To verify this, keep sleep time between enqueues "\
    "relatively high, but expect to see 20 values (0-19) for 20 urls. "\
    "This automated test only checks that there is number equal or greater "\
    "than 19 there. For 'real' test check audit log manually.")

  sleep_time_between_enqueues = 10

  max_count = 50
  max_url = 5
  max_value = Array.new(max_url-1,0)

  stop(server2_c)

  # Perform enqueues
  max_count.times do |i|
    which_url=rand(max_url)
    max_value[which_url]=i
    target_host = [server1_c, client_c].sample
    enqueue_multiple(target_host, results,
      "No-reuse-#{which_url.to_s}", i.to_s)
    # Even with sleep time of 10 here, there should be 20 different vertices
    # in the log, 0-19, one per url
    sleep sleep_time_between_enqueues
  end

  start(server2_c)

  sleep sleep_time_between_enqueues

  # This one may or may not reuse a vertex, but should get to client
  enqueue_multiple(server2_c, results, "extra", "extra")

  audit_log_on_client =
    check_and_purge_audit_log(client_c, results, "successful", 204)

  # Verify that client has expected value for each url
  max_url.times do |y|
    verify_value(results, client_c, "No-reuse-#{y.to_s}",
      max_value[y].to_s)
  end
  verify_value(results, client_c, "extra", "extra")

  # Check vertex reuse on client
  min_vertex, max_vertex = get_vertex_range_from_audit_log(audit_log_on_client)
  if (max_vertex)
    results.add(max_vertex >= 19,
      "Min value of vertex is #{min_vertex}, max value of vertex is "\
      "#{max_vertex}, indicating no vertex reuse on client",
      "Min value of vertex is #{min_vertex}, max value of vertex is "\
      "#{max_vertex}, indicating vertex reuse on client")
  else
    results.add_failure("No entries in audit log to check for vertex reuse")
  end

  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# Test for a resolved(fixed) issue
def bug_29402(server1_c, server2_c, client_c, results)
  print_test_header("Bug-29402",
    "Bug-29402 caused the following incorrect behavior: "\
    "an update, received from a server after client's "\
    "crawler was stopped and resumed, was incorrectly "\
    "rejected by the client with siphoned=remote-conflict "\
    "error. As a result, url Foo cannot be found on client. "\
    "Another way to see the bug would be to see the error in "\
    "the audit log instead of successful entry.")

  stop(client_c)
  enqueue_no_verify(server1_c, results, "Enqueue-on-server",
    "Enqueue-on-server")
  stop(server1_c)
  start(client_c)
  enqueue_no_verify(client_c, results, "Enqueue-on-client",
    "Enqueue-on-client")
  delete_no_verify(client_c, results, "Enqueue-on-client")
  stop(client_c)
  start(client_c)
  start(server1_c)
  check_and_purge_audit_log(client_c, results, "successful", 3)
  verify_value(results, client_c, "Enqueue-on-server", "Enqueue-on-server")
  # Cleanup
  purge_audit_log(server1_c)
  purge_audit_log(server2_c)
end

# ----------------- Main ------------------ #

# Setup the test
results = TestResults.new(
            'Configuration consists of two servers and one client.',
            'Test conflict resolution ')

results.need_system_report = false

# Setup (seed) randomizer for use in tests
seed = Time.now.usec
msg "Seeding randomizer with #{seed}"
srand(seed)

# Setup hosts
SERVER1_NAME = "repl-synch-1-s1"
SERVER2_NAME = "repl-synch-1-s2"
CLIENT_NAME = "repl-synch-1-c1"
SERVER1_PORT = "40412"
SERVER2_PORT = "40513"

server1_c, server2_c, client_c = setup(results, SERVER1_NAME, SERVER2_NAME,
                                        CLIENT_NAME, SERVER1_PORT,
                                        SERVER2_PORT)

# Execute tests
check_configuration(server1_c, server2_c, client_c, results)
earlier_update_does_not_override_later_update(server1_c, server2_c,
  client_c, results)
later_update_overrides_earlier_update(server1_c, server2_c, client_c, results)
continuous_conflicts_servers(server1_c, server2_c, client_c, results)
continuous_conflicts_all_hosts(server1_c, server2_c, client_c, results)
vertices_reuse(server1_c, server2_c, client_c, results)
no_vertices_reuse_while_server_offline(server1_c, server2_c,
  client_c, results)
bug_29402(server1_c, server2_c, client_c, results)

msg "-----------------------"
results.cleanup_and_exit!
