#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/replicated-synch'

require 'misc'
require 'host_env'
require 'host_wrappers'
require 'repl-synch-common'

def crawler_counts(c)
  Hash[*c.status.xpath('/vse-status/crawler-status').first.attributes.
    map{|k,v| [k.to_s, v.to_s]}.select{|k,v| k[0..1] == 'n-'}.flatten]
end

results = TestResults.new("With a simple distributed server & client,",
                          "make sure the client doesn't crash and",
                          "the stats don't get all wonky when we:",
                          "1. Send a delete for a bogus URL to the server.",
                          "2. Enqueue a url to the server and delete that url.",
                          "",
                          "This is a test for bug 26189.")

PORT=40404
server_c, server_addr = host_collection('repl-stats-server')
client_c, client_addr = host_collection('repl-stats-client')

results.associate(server_c)
results.associate(client_c)

server_c.delete
server_c.create
configure_remote_common(server_c)
configure_remote_server(server_c, client_c.name, PORT)

client_c.delete
client_c.create
configure_remote_common(client_c)
configure_remote_client(client_c, server_c.name, '%s:%s'%[server_addr, PORT])

server_c.crawler_start
client_c.crawler_start

nonzero = crawler_counts(client_c).reject{|k,v| v[/0*.0*/]==v}
results.add(nonzero.length==0,
            'client crawler stat counts are all zero',
            'Nonzero client crawler stat counts %s' % nonzero.inspect)

# Delete bogus URL
results.add((not server_c.enqueue_xml('<crawl-delete vse-key="bogus" synchronization="indexed-no-sync"/>')),
            'Delete a bogus key failed, as expected.',
            'Deleting a bogus key succeeded! This is bad.')

sleep 5
nonzero = crawler_counts(client_c).reject{|k,v| v[/0*.0*/]==v}
results.add(nonzero.length==0,
            'client crawler stat counts are all zero',
            'Nonzero client crawler stat counts %s' % nonzero.inspect)

CRAWL_URL = '<crawl-url status="complete" url="http://doc1:80/" synchronization="indexed-no-sync">
  <crawl-data content-type="text/plain" encoding="text">
    Nothing to see here in document %d.
  </crawl-data>
</crawl-url>'

# Enqueue
results.add(server_c.enqueue_xml(CRAWL_URL%[1,1]),
            'Enqueued a simple doc.')

sleep 5
nonzero = crawler_counts(client_c).reject{|k,v| v[/0*.0*/]==v}
results.add(nonzero.length==0,
            'client crawler stat counts are all zero',
            'Nonzero client crawler stat counts %s' % nonzero.inspect)

# Delete good
results.add(server_c.enqueue_xml('<crawl-delete vse-key="http://doc1:80/" synchronization="indexed-no-sync"/>'),
            'Deleted a real doc.')

sleep 5
nonzero = crawler_counts(client_c).reject{|k,v| v[/0*.0*/]==v}
results.add(nonzero.length==0,
            'client crawler stat counts are all zero',
            'Nonzero client crawler stat counts %s' % nonzero.inspect)

results.cleanup_and_exit!
