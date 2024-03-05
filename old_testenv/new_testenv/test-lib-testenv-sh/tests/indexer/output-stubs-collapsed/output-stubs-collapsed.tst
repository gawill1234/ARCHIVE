#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/'

require 'misc'
require 'collection'
require 'indexer_http'
require 'output_stubs'

results = TestResults.new('Ensure that the indexer returns the proper',
                          'set of attributes when returning stubs that',
                          'contain collapsed documents')
results.need_system_report = false

c = Collection.new(TESTENV.test_name)
results.associate(c)
c.delete
c.create
c.set_index_options(:duplicate_elimination => true)

input_doc = <<END
<crawl-urls>
<crawl-url url="api://127.0.0.1/1" vse-key="key:1" synchronization="indexed">
  <crawl-data content-type="application/vxml">
    <vxml>
      <document>
        <content name="title" type="text" weight="3">Hello!</content>
        <content name="collapse-key" type="text" fast-index="set">apple</content>
      </document>
    </vxml>
  </crawl-data>
</crawl-url>
<crawl-url url="api://127.0.0.1/2" vse-key="key:2" synchronization="indexed">
  <crawl-data content-type="application/vxml">
    <vxml>
      <document>
        <content name="title" type="text" weight="1">Hello!</content>
        <content name="collapse-key" type="text" fast-index="set">apple</content>
      </document>
    </vxml>
  </crawl-data>
</crawl-url>
</crawl-urls>
END
input_doc = Nokogiri::XML(input_doc)

c.enqueue_xml(input_doc)

indexer = IndexerHTTP.new(c.name)
res = indexer.search(:num => 10, :collapse_xpath => '$collapse-key', :n_collapse => 10, :stubs => 1)

top_docs = res.xpath('/*/document')
results.add_number_equals(1, top_docs.count, 'top-level document')

top_doc = top_docs.first
results.test_stub_document(top_doc)

collapsed_docs = top_doc.xpath('vse-collapsed/document')
results.add_number_equals(1, collapsed_docs.count, 'collapsed document')

collapsed_doc = collapsed_docs.first
# remove these two attributes by hand until bug 27242 is fixed
collapsed_doc.remove_attribute('score')
collapsed_doc.remove_attribute('mwi-shingle')
results.test_stub_document(collapsed_doc)

results.cleanup_and_exit!
