#!/usr/bin/env ruby

require 'pmap'
require 'misc'
require 'collection'

N = (ARGV[0] || 10000).to_i

results = TestResults.new("Performance check for repository-list-xml",
                          "on a Velocity system with many collections.")

# Setup a base collection with the smallest possible memory footprint
base = Collection.new("bug-20604-base")
base.vapi.collection_broker_start
results.associate(base)
base.delete
base.create("default-broker-push")
base.set_crawl_options({:cache_size => 0}, {})
base.set_index_options(:cache_mb => 0, :cache_cleaner_mb => 0)

msg 'Beginning creation of %d collections' % N
start = Time.now
(0...N).to_a.peach {|j|
  c = Collection.new("bug-20604-c%05d" % j)
  msg "Creating collection '#{c.name}'." if j % 100 == 0
  c.create
}
elapsed = Time.now-start
msg 'Collection creation completed in %f minutes.' % (elapsed/60.0)

start = Time.now
rlx = base.vapi.repository_list_xml
elapsed = Time.now-start
r_count = rlx.xpath('/vce/vse-collection').count
msg 'Found a total of %d collections on the target Velocity system.' % r_count
results.add(elapsed < 2, 'repository-list-xml took %.3f seconds.' % elapsed)

start = Time.now
cbs = base.vapi.collection_broker_status
elapsed = Time.now-start
cb_count = cbs.xpath('/collection-broker-status-response/collection').count
msg 'Collection broker status reports %d collections.' % cb_count
results.add(elapsed < 2, 'collection-broker-status took %.3f seconds.' % elapsed)

results.cleanup_and_exit!
