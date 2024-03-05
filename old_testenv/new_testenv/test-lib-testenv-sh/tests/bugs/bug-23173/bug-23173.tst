#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'

results = TestResults.new('Make sure caron diacritics are removed from Z.')

collection = Collection.new('bug-23173')
results.associate(collection)

collection.delete
collection.create
collection.crawler_start
collection.indexer_start

CRAWL_URL = '
<crawl-urls synchronization="indexed-no-sync" >
  <crawl-url status="complete" url="http://bug/doc-0">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here.  Testing for character Žoo and žany.
    </crawl-data>
  </crawl-url>
</crawl-urls>'

results.add(collection.enqueue_xml(CRAWL_URL),
            "Successfully enqueued document.",
            "Failed to enqueue document.")
qr = collection.search('zoo')
doc_count = qr.xpath('/query-results/list/document').length

results.add(doc_count == 1,
            "Found #{doc_count} results.")

qr = collection.search('zany')
doc_count = qr.xpath('/query-results/list/document').length

results.add(doc_count == 1,
            "Found #{doc_count} results.")

results.cleanup_and_exit!
