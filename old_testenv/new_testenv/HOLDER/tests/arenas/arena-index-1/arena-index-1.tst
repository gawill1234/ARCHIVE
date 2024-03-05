#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'
require 'arenas-helpers'

def wrap(stuff)
  '<crawl-urls synchronization="indexed-no-sync" >%s</crawl-urls>' % stuff
end

results = TestResults.new('Crawl a set of documents into a non-arena collection. ',
                          'Crawl same set of documents splitting into multiple ',
                          'arenas.  Make sure the resources used are similar.')

CRAWL_URL_NO_ARENA = '<crawl-url status="complete" url="http://lince/doc-%d">
<crawl-data content-type="text/plain" encoding="text">
  Nothing to see here in document %d.
</crawl-data></crawl-url>'

CRAWL_URL = '<crawl-url status="complete" url="http://lince/doc-%d" arena="arena-%d">
<crawl-data content-type="text/plain" encoding="text">
  Nothing to see here in document %d.
</crawl-data></crawl-url>'

COUNT=10000
ARENA_COUNT=4
FILESIZE_THRESHOLD=10 # percentage difference

c_no_arena = Collection.new('arena-index-1-no-arena')
results.associate(c_no_arena)
c_no_arena.delete
c_no_arena.create
c_no_arena.crawler_start
c_no_arena.indexer_start
msg "Collection #{c_no_arena.name} setup without arenas."

crawl_nodes_no_arena = wrap((0...COUNT).map {|i| CRAWL_URL_NO_ARENA % [i, i]}.join())
results.add(c_no_arena.enqueue_xml(crawl_nodes_no_arena), "#{COUNT} documents enqueued")

c = Collection.new('arena-index-1')
results.associate(c)
c.delete
c.create
configure_arenas(c, 'true')
c.crawler_start
c.indexer_start
crawl_nodes = wrap((0...COUNT).map {|i| CRAWL_URL%[i, i % ARENA_COUNT, i]}.join())
results.add(c.enqueue_xml(crawl_nodes), "#{COUNT} documents enqueued into #{ARENA_COUNT} arenas.")

until c.indexer_idle?
  sleep 1
end

# Check resources
no_arena_filesize = c_no_arena.get_index_size
arena_filesize = c.get_index_size
filesize_diff = ( (arena_filesize - no_arena_filesize).abs / arena_filesize.to_f ) * 100

results.add(filesize_diff < FILESIZE_THRESHOLD,
            "Arena-enabled index filesize is #{arena_filesize}, non-arena filesize is #{no_arena_filesize}",
            "Arena-enabled index filesize is #{arena_filesize}, non-arena filesize is #{no_arena_filesize}, expected a difference of less than #{FILESIZE_THRESHOLD}%")

# Cleanup
c_no_arena.stop
c.stop

results.cleanup_and_exit!
