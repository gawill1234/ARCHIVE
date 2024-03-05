#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/'

require 'misc'
require 'collection'
require 'indexer_http'
require 'output_stubs'

results = TestResults.new('Ensure that the indexer returns the proper',
                          'set of attributes when returning stubs')
results.need_system_report = false

c = Collection.new(TESTENV.test_name)
results.associate(c)
c.delete
c.create
c.set_index_options(:duplicate_elimination => true)

input_doc = <<END
<crawl-url url="api://127.0.0.1/1" vse-key="key:1" synchronization="indexed">
  <crawl-data content-type="application/vxml">
    <vxml>
      <document>
        <content name="title" type="text">Hello!</content>
      </document>
    </vxml>
  </crawl-data>
</crawl-url>
END
input_doc = Nokogiri::XML(input_doc)

c.enqueue_xml(input_doc)

indexer = IndexerHTTP.new(c.name)
res = indexer.search(:stubs => 1)

docs = res.xpath('//document')
results.add_number_equals(1, docs.count, 'document')

doc = docs.first
results.test_stub_document(doc)

results.cleanup_and_exit!
