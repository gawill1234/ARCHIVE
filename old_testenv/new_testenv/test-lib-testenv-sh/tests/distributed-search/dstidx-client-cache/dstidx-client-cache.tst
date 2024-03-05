#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/replicated-synch/'

require "misc"
require "collection"
require "repl-synch-common"
require 'timeout'

results = TestResults.new('Documents on the distributed indexing client should be cached')
results.need_system_report = false

def configure_remote_server_and_client(results)
  server = Collection.new("#{TESTENV.test_name}-server")
  server.delete
  server.create('example-metadata')

  client = Collection.new("#{TESTENV.test_name}-client")
  client.delete
  client.create('default') # Pick a default that enables the cache

  port = 12322

  configure_remote_common(server)
  configure_remote_server(server, client.name, port)

  configure_remote_common(client)
  configure_remote_client(client, server.name, "127.0.0.1:#{port}")

  results.associate(server)
  results.associate(client)

  return server, client
end

def crawl_and_distribute_documents(server, client)
  Timeout::timeout(10) do
    server.crawler_start
    server.wait_until_idle
  end

  Timeout::timeout(10) do
    client.crawler_start
    client.wait_until_idle
  end
end

def it_caches_documents_on_the_client(client, results)
  doc = client.search("Slow Leak", :output_cache_data => true).xpath('//document').first
  cache = doc.xpath('cache').first
  results.add_matches(/a forgotten incident in her past/, cache.text, :what => 'cache text')
end

server, client = configure_remote_server_and_client(results)
crawl_and_distribute_documents(server, client)
it_caches_documents_on_the_client(client, results)

results.cleanup_and_exit!(true)
