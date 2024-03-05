#!/usr/bin/env ruby

require 'misc'
require 'collection'

results = TestResults.new('Make sure value < $variable is correct.')

collection = Collection.new('bug-23972')
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
          <content name="int">1</content>
        </document>
        <document url="http://bug?doc-1">
          <content name="int">100</content>
        </document>
        <document url="http://bug?doc-2">
          <content name="int">1000</content>
        </document>
        <document url="http://bug?doc-3">
          <content name="int">500</content>
        </document>
      </vce>
    </crawl-data>
  </crawl-url>
</crawl-urls>'

QUERY_NODE1 = '<term field="v.xpath" str="500 &gt; $int"/>'
QUERY_NODE2 = '<term field="v.xpath" str="100 &lt; $int"/>'

results.add(collection.enqueue_xml(CRAWL_URL),
            "Successfully enqueued document.",
            "Failed to enqueue document.")

qr = collection.search(nil, :query_object => QUERY_NODE1)
doc_count = qr.xpath('/query-results/list/document').length

results.add(doc_count == 2,
            "Found #{doc_count} results.")
vals = qr.xpath('/query-results/list/document/content[@name="int"]')
for item in vals
  results.add(500 > item.content.to_i ,
              "#{item.content.to_i} is less than 500",
              "#{item.content.to_i} is greater than 500")
end

qr = collection.search(nil, :query_object => QUERY_NODE2)
doc_count = qr.xpath('/query-results/list/document').length

results.add(doc_count == 2,
            "Found #{doc_count} results.")

vals = qr.xpath('/query-results/list/document/content[@name="int"]')
for item in vals
  results.add(100 < item.content.to_i ,
              "#{item.content.to_i} is greater than 100",
              "#{item.content.to_i} is less than 100")
end

results.cleanup_and_exit!
