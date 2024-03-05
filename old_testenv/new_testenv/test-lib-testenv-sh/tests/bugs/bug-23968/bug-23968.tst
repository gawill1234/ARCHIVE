#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new('Make sure that has-one-of($int, ...) does not crash.')

collection = Collection.new('bug-23968')
results.associate(collection)

collection.delete
collection.create
collection.set_index_options(:fast_index => "int")
collection.crawler_start
collection.indexer_start

CRAWL_URL = '
<crawl-urls synchronization="indexed-no-sync" >
  <crawl-url status="complete" url="http://bug">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <vce>
        <document url="http://bug?doc-0">
          <content name="int">12</content>
        </document>
        <document url="http://bug?doc-1">
          <content name="int">13</content>
        </document>
        <document url="http://bug?doc-2">
          <content name="int">14</content>
        </document>
        <document url="http://bug?doc-3">
          <content name="int">15</content>
        </document>
      </vce>
    </crawl-data>
  </crawl-url>
</crawl-urls>'

QUERY_NODE = '<term field="v.xpath" str="viv:has-one-of($int, 14, 13)"/>'

results.add(collection.enqueue_xml(CRAWL_URL),
            "Successfully enqueued document.",
            "Failed to enqueue document.")

qr = collection.search(nil, :query_object => QUERY_NODE)
doc_count = qr.xpath('/query-results/list/document').length

results.add(doc_count == 2,
            "Found #{doc_count} results.")

results.cleanup_and_exit!
