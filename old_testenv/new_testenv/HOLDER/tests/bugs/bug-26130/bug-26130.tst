#!/usr/bin/env ruby

require 'pmap'
require 'misc'
require 'collection'

CRAWL_URLS = '<crawl-urls synchronization="indexed-no-sync" >
  <crawl-url status="complete" url="http://%s">
    <crawl-data content-type="text/plain">
      My name is "%s".
    </crawl-data>
  </crawl-url>
</crawl-urls>'

N = 40000

threads = (ARGV[0] || 10).to_i

results = TestResults.new("Exercise creating and starting #{N} collections.",
                          "In #{threads} parallel threads:",
                          "    1. Create a collection,",
                          "    2. Enqueue one trivial document,",
                          "    3. Expect to find the document with a search,",
                          "    4. Kill the crawler and indexer.")

# Setup a base collection with the smallest possible memory footprint
base = Collection.new("bug-26130-base")
results.associate(base)
base.delete
base.create("default-push")
base.set_crawl_options({:cache_size => 0}, {})
base.set_index_options(:cache_mb => 0, :cache_cleaner_mb => 0)

(0..N).to_a.peach(threads) {|j|
  c = Collection.new("bug-26130-c%05d" % j)
  msg "Creating collection '#{c.name}'." if j % 100 == 0
  c.create(base.name)
  results.add(false, "Enqueue failed to #{c.name}") unless
    c.enqueue_xml(CRAWL_URLS % [c.name, c.name])
  tr = c.search_total_results
  results.add_equals(1, tr, "total search results for #{c.name}") if tr != 1
  c.kill
}

results.cleanup_and_exit!
