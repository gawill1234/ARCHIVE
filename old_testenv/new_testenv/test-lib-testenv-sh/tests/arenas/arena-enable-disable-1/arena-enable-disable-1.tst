#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'time'
require 'misc'
require 'collection'
require 'arenas-helpers'

def check_results(collection, expect, arena = nil)
  if arena then
    qr = collection.vapi.query_search(:sources => collection.name,
                                      :arena => arena)
  else
    qr = collection.vapi.query_search(:sources => collection.name)
  end

  doc_count = qr.xpath('/query-results/list/document').length
  [doc_count == expect,
   "#{doc_count} documents found.",
   "#{doc_count} documents found (expected #{expect})."]
end

results = TestResults.new('Create and start a collection with arenas disabled, ',
			  'enqueue a document into the collection, ',
                          'verify that an empty query returns the document. ',
                          'Update the collection to enable arenas, ',
                          'then do an empty query again. Verify document is there.',
                          'Create a new collection with arenas enabled, ',
                          'then enqueue a document specifying a new arena. ',
                          'An empty query of the arena should return the doc. ',
                          'Update the collection to disable arenas, then ',
                          'do an empty query with no arena specified. ',
                          'Results should be empty this time.',
                          'Finally: empty query of the arena should return ',
                          'document and a warning.')


CRAWL_URL_NO_ARENA = '<crawl-urls synchronization="indexed-no-sync" >
<crawl-url status="complete" url="http://lince/doc-no-arena" >
  <crawl-data content-type="text/plain" encoding="text">
    Nothing to see here in this item.
  </crawl-data>
</crawl-url></crawl-urls>'

CRAWL_URL_WITH_ARENA = '<crawl-urls synchronization="indexed-no-sync" >
<crawl-url status="complete" url="http://lince/doc-with-arena" arena="arena1">
  <crawl-data content-type="text/plain" encoding="text">
    Nothing to see here unless you are in my arena.
  </crawl-data>
</crawl-url></crawl-urls>'

# First create collection without arenas
c = Collection.new('arena-enable-disable-1')
results.associate(c)
c.delete
c.create
c.indexer_start

msg "Collection #{c.name} setup without arenas."

results.add(c.enqueue_xml(CRAWL_URL_NO_ARENA), "document indexed")
results.add(*check_results(c, 1))
c.stop

# Now enable arenas in collection

# TODO:
# Need to check for warnings when configuring arenas in a non-arena collection?
configure_arenas(c, 'true')
c.indexer_start

msg "Collection #{c.name} restarted with arenas configured."
results.add(*check_results(c, 1))
c.stop

c.delete
c.create
configure_arenas(c, 'true')
msg "Collection #{c.name} recreated with arenas configured."
c.indexer_start

results.add(c.enqueue_xml(CRAWL_URL_WITH_ARENA), "document with arena indexed")
results.add(*check_results(c, 1, 'arena1'))
c.stop

# TODO: check for warnings again?
configure_arenas(c, 'false')
msg "Collection #{c.name} stopped and reconfigured without arenas."
c.indexer_start
results.add(*check_results(c, 0))
c.stop

msg "Collection #{c.name} stopped.  Checking to see if indexer starts automatically."
results.add(*check_results(c, 1, 'arena1'))
c.stop

results.cleanup_and_exit!
