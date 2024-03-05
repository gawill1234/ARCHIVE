#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/'

require 'misc'
require 'collection'
require 'indexer_http'

results = TestResults.new('Ensure that the indexer properly collapses documents')
results.need_system_report = false

c = Collection.new(TESTENV.test_name)
results.associate(c)
c.delete
c.create

input_doc = <<END
<crawl-urls>
<crawl-url url="api://127.0.0.1/1" vse-key="key:1" synchronization="indexed">
  <crawl-data content-type="application/vxml">
    <vxml>
      <document>
        <content name="title" type="text">Hello!</content>
        <content name="collapse-key" type="text" fast-index="set">apple</content>
        <content name="rank" type="text" fast-index="int">1</content>
      </document>
    </vxml>
  </crawl-data>
</crawl-url>
<crawl-url url="api://127.0.0.1/2" vse-key="key:2" synchronization="indexed">
  <crawl-data content-type="application/vxml">
    <vxml>
      <document>
        <content name="title" type="text">Hello!</content>
        <content name="collapse-key" type="text" fast-index="set">apple</content>
        <content name="rank" type="text" fast-index="int">2</content>
      </document>
    </vxml>
  </crawl-data>
</crawl-url>
</crawl-urls>
END
input_doc = Nokogiri::XML(input_doc)

c.enqueue_xml(input_doc)

indexer = IndexerHTTP.new(c.name)
res = indexer.search(:num => 1, :collapse_xpath => '$collapse-key', :n_collapse => 10, :collapse_sort => '$rank')

top_docs = res.xpath('/*/document')
results.add_number_equals(1, top_docs.count, 'top-level document')

top_doc = top_docs.first
results.add_equals('key:1', top_doc['vse-key'], 'top-level document vse-key')

collapsed_docs = top_doc.xpath('vse-collapsed/document')
results.add_number_equals(1, collapsed_docs.count, 'collapsed document')

collapsed_doc = collapsed_docs.first
results.add_equals('key:2', collapsed_doc['vse-key'], 'collapsed document vse-key')

results.cleanup_and_exit!
