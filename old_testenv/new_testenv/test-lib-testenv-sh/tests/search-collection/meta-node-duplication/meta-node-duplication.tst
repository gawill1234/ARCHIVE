#!/usr/bin/env ruby

require 'misc'
require 'collection'

meta = <<EOF
<vse-meta>
  <vse-meta-info>
    <live-crawl-dir>a</live-crawl-dir>
    <staging-crawl-dir>b</staging-crawl-dir>
    <live-index-file>c</live-index-file>
    <staging-index-file>d</staging-index-file>
    <index-dir>e</index-dir>
    <cache-dir>f</cache-dir>
    <live-log-dir>g</live-log-dir>
    <staging-log-dir>h</staging-log-dir>
    <maintainers>i</maintainers>
    <read-only>read-only</read-only>
    <enable-remote>enable-remote</enable-remote>
  </vse-meta-info>
</vse-meta>
EOF

def get_info_nodes(collection)
  b = collection.xml

  info_nodes = b.xpath("/*/vse-meta/vse-meta-info")
  hidden_info_nodes = b.xpath("/*/hidden/vse-meta/vse-meta-info")

  return [info_nodes, hidden_info_nodes]
end

def ensure_count(results, expected, actual)
  results.add(expected == actual, "Found all #{expected} meta nodes", "Got #{actual} meta nodes, but expected #{expected}")
end

def ensure_counts_are_correct(results, collection, original_node_count)
  info_nodes, hidden_info_nodes = get_info_nodes(collection)
  new_node_count = info_nodes.length
  new_hidden_node_count = hidden_info_nodes.length

  ensure_count(results, original_node_count, new_node_count)
  ensure_count(results, original_node_count, new_hidden_node_count)
end

results = TestResults.new('Creates a collection with many meta nodes and ensures they do not get duplicated', 'Corresponds to bug 22010')
results.need_system_report = false

collection = Collection.new('double-meta')
collection.delete()
collection.create('default', meta, 'I should have a description')

info_nodes, hidden_info_nodes = get_info_nodes(collection)
original_node_count = info_nodes.length
original_hidden_node_count = hidden_info_nodes.length

# There are 11 specific meta nodes above, plus the description
ensure_count(results, 12, original_node_count)
ensure_count(results, 0, original_hidden_node_count)

# This will start the collection-service, which will create the hidden node
collection.crawler_kill()
ensure_counts_are_correct(results, collection, original_node_count)

msg('sleeping to allow the collection-service to exit')
sleep(40)
collection.crawler_kill()
ensure_counts_are_correct(results, collection, original_node_count)

results.cleanup_and_exit!
