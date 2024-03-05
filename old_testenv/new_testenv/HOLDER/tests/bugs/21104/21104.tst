#!/usr/bin/env ruby

require 'misc'
require 'collection'

def wrap(stuff)
   '<crawl-urls synchronization="indexed-no-sync" >%s</crawl-urls>' % stuff
end

results = TestResults.new('Enqueue 10000 documents with the same vse-key and ',
                          'make sure that on a delete all documents are ',
                          'deleted at the same time.')

def get_document_size(c)
  doc_as_xml = ""
  qr = c.vapi.query_search(:sources => c.name)
  doc = qr.
    xpath("/query-results/list/document")
  if doc.first != nil
    doc_as_xml = doc.first.to_xml
  end

  return doc_as_xml.size
end

DOC_COUNT = 10000
CRAWL_URL = '
<crawl-url status="complete" url="http://lince/doc-%d" forced-vse-key="test">
  <crawl-data content-type="text/plain" encoding="text">
    Nothing to see here in document %d.
  </crawl-data>
</crawl-url>'

CRAWL_DELETE = '<crawl-delete vse-key="%s" synchronization="enqueued" />'


c = Collection.new('bug-21104')
c.delete
c.create
c.set_crawl_options({:atomic_vse_key_delete_mode => true}, {})
c.set_index_options(:max_output_contents => 0)
results.associate(c)
c.crawler_start
c.indexer_start
msg "Collection bug-21104 started."

msg "Enqueuing #{DOC_COUNT} documents to bug-21104."
crawl_nodes = wrap((0...DOC_COUNT).map {|i| CRAWL_URL%[i, i]}.join())
results.add(c.enqueue_xml(crawl_nodes),
            "#{DOC_COUNT} documents enqueued successfully.",
            "Failed to enqueue documents to collection bug-21104")

until c.indexer_idle?
  sleep 1
end

n_docs = c.search_total_results
results.add(n_docs == 1,
            "Found #{1} documents in collection bug-21104.",
            "Found #{n_docs} documents in collection bug-21104, expected 1.")

initial_size = get_document_size(c)

msg "Enqueuing a vse-key delete for all #{DOC_COUNT} documents."

# Find the document's vse-key
qr = c.vapi.query_search(:sources => c.name)
doc = qr.
  xpath("/query-results/list/document")
key_to_delete = doc.first['vse-key']
c.enqueue_xml(CRAWL_DELETE % key_to_delete)

msg "Confirm that there are no results left atomically."
n_docs = c.search_total_results
time_to_wait = Time.now + 60 # wait at most one minute
while n_docs != 0 and Time.now < time_to_wait

  size = get_document_size(c)
  results.add(size == initial_size || size == 0,
              "Found doc size = #{size} bytes",
              "Found doc size = #{size} bytes, expected #{initial_size} bytes or 0 bytes.")
  sleep 5
  n_docs = c.search_total_results
end

results.add(n_docs == 0,
            "Collection is empty as expected.",
            "Collection returned #{n_docs} documents, expected an empty collection.")

results.cleanup_and_exit!
