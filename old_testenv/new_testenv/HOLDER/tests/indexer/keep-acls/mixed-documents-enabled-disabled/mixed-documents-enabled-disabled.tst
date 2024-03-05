#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/keep-acls'

require 'misc'
require 'collection'

results = TestResults.new("Ensure that mixing documents with keep-acls turned on and off works")
results.need_system_report = false

collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create('default-push')

def dummy_url(value)
  url_str = <<EOF
<crawl-url url="#{value}" synchronization="indexed" status="complete">
  <crawl-data encoding="xml" content-type="application/vxml">
    <document>
      <content name="main" acl="#{value}">data#{value}</content>
    </document>
  </crawl-data>
</crawl-url>
EOF
  return Nokogiri::XML(url_str).root
end

class Collection
  def set_and_stop(options)
    set_index_options(options)
    crawler_stop
    indexer_stop
  end
end

collection.set_and_stop(:keep_acls => true)
collection.enqueue_xml(dummy_url(1))

collection.set_and_stop(:keep_acls => false)
collection.enqueue_xml(dummy_url(2))

collection.set_and_stop(:keep_acls => true)
collection.enqueue_xml(dummy_url(3))

collection.set_and_stop(:output_acls => true)
res = collection.search

documents = res.xpath('//document')
results.add_number_equals(3, documents.size, 'document')

content1 = documents[0].xpath('content').first
content2 = documents[1].xpath('content').first
content3 = documents[2].xpath('content').first

results.add_equals('1', content1['acl'], 'acl attribute')
results.add_equals(nil, content2['acl'], 'acl attribute')
results.add_equals('3', content3['acl'], 'acl attribute')

results.cleanup_and_exit!(true)
