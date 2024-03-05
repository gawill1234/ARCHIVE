#!/usr/bin/env ruby

require 'misc'
require 'collection'

meta = <<EOF
<vse-meta>
  <vse-meta-info>
    <live-crawl-dir>a</live-crawl-dir>
    <staging-crawl-dir>b</staging-crawl-dir>
  </vse-meta-info>
</vse-meta>
EOF

def ensure_meta_nodes(results, collection, names, bad_names=[])
  x = collection.xml

  for meta_name in names do
    info = x.xpath("/*/vse-meta/vse-meta-info[@name = '#{meta_name}']")
    present = (info != nil && info.size == 1)
    results.add(present, "found a meta node for #{meta_name}", "did not find a meta node for #{meta_name}")
  end

  for meta_name in bad_names do
    info = x.xpath("/*/vse-meta/vse-meta-info[@name = '#{meta_name}']")
    missing = (info == nil || info.size == 0)
    results.add(missing, "did not find a meta node for #{meta_name}", "found a meta node for #{meta_name}")
  end
end

results = TestResults.new('Creates collections with different combinations of meta nodes and descriptions', 'Corresponds to bug 23718')
results.need_system_report = false

collection = Collection.new('meta-and-description')
collection.delete()
collection.create_raw('default', meta, 'I have a description')
ensure_meta_nodes(results, collection, ['live-crawl-dir', 'staging-crawl-dir', 'desc'])

collection = Collection.new('description-only')
collection.delete()
collection.create_raw('default', nil, 'I have a description')
ensure_meta_nodes(results, collection, ['desc'], ['live-crawl-dir', 'staging-crawl-dir'])

collection = Collection.new('meta-only')
collection.delete()
collection.create_raw('default', meta, nil)
ensure_meta_nodes(results, collection, ['live-crawl-dir', 'staging-crawl-dir'], ['desc'])

results.cleanup_and_exit!
