#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT'] + '/tests/arenas'

require 'misc'
require 'collection'
require 'arenas-helpers'

def check_results(collection, expect, arena = nil, query = nil)
  error = false
  if arena then
    qr = collection.vapi.query_search(:sources => collection.name,
                                      :arena => arena,
				      :query => query)
  else
    # If querying without arenas, check that an error was returned.
    qr = collection.vapi.query_search(:sources => collection.name)
    err_msg = qr.xpath('/query-results/added-source/log/error/@id').first.to_s
    if err_msg != 'SEARCH_ENGINE_SEARCH_ARENAS_MISSING_ARENA' then
      return [false, 
              "not used",
              "Expected error: SEARCH_ENGINE_SEARCH_ARENAS_MISSING_ARENA, " +
              "got %s" % err_msg]
    end
  end
  doc_count = qr.xpath('/query-results/list/document').length
  [doc_count == expect && ! error,
   "#{doc_count} documents found.",
   "#{doc_count} documents found (expected #{expect}, )."]
end

def wrap(stuff)
  '<crawl-urls synchronization="indexed-no-sync" >%s</crawl-urls>' % stuff
end

results = TestResults.new('Create a collection with ten documents each with ',
                          'a unique arena.  Make sure searches only return ',
                          'documents in the specified arena.')

CRAWL_URL_NO_ARENA = '<crawl-url status="complete" url="http://lince/doc-no-arena">
<crawl-data content-type="text/plain" encoding="text">
  Nothing to see here in document with no arena specified.
</crawl-data></crawl-url>'

CRAWL_URL = '<crawl-url status="complete" url="http://lince/doc-%d" arena="arena-%d">
<crawl-data content-type="text/plain" encoding="text">
  Nothing to see here in document %d.
</crawl-data></crawl-url>'

# Create collection with arenas enabled
COUNT = 10

c = Collection.new('arena-crawl-search-1')
results.associate(c)
c.delete
c.create
configure_arenas(c, 'true')
c.indexer_start
msg "Collection #{c.name} setup with arenas configured."

crawl_nodes = wrap((0...COUNT).map {|i| CRAWL_URL % [i, i, i]}.join())
results.add(c.enqueue_xml(crawl_nodes), "#{COUNT} documents indexed.")

doc_count = c.index_n_docs
results.add(
            doc_count == COUNT,
            "#{doc_count} documents found in index.",
            "#{doc_count} documents found in index, expected #{COUNT}."
            )

# Make sure that enqueueing a document with no arena fails
results.add(
            !c.enqueue_xml(wrap(CRAWL_URL_NO_ARENA)),
            "Document with no arena failed to be enqueued.",
            "Document with no arena was added successfully."
            )

msg "Running searches on collection #{c.name} with and without arenas defined."
results.add(*check_results(c, 1, 'arena-0'))
results.add(*check_results(c, 0, 'NA'))
results.add(*check_results(c, 0))
results.add(*check_results(c, 1, 'arena-0', 'Document 0'))
results.add(*check_results(c, 0, 'arena-0', 'Document 1'))
results.add(*check_results(c, 1, 'arena-0', 'Document'))

# Check that there are at least ten internal unique stream/arena identifiers
num_streams = c.get_number_streams
results.add(num_streams >= COUNT,
            "Found #{num_streams} streams.",
            "Found #{num_streams} streams, expected at least #{COUNT}."
            )
c.stop

results.cleanup_and_exit!
