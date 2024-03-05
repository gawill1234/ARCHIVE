#!/usr/bin/env ruby

$LOAD_PATH << ENV['TEST_ROOT']+'/lib'

require 'misc'
require 'collection'

results = TestResults.new("Repeatedly kill the crawler as it tries to",
                          "process enqueued data. Check that no delete",
                          "references exist at the end.")
results.need_system_report = false

dummy = <<EOF
<crawl-url synchronization="enqueued" status="complete">
  <crawl-data encoding="text">hello world</crawl-data>
</crawl-url>
EOF
dummy = Nokogiri.XML(dummy).root
doc = dummy.document

enqueue_data = doc.create_element('crawl-urls')
1000.times do |i|
  cu = dummy.clone
  cu['url'] = "http://127.0.0.1/#{i}"
  enqueue_data << cu
end

collection = Collection.new(TESTENV.test_name)
results.associate(collection)

collection.delete
collection.create('default-push')
collection.enqueue_xml(enqueue_data)
msg "Pushed initial data"

10.times do |i|
  # Give the crawler a second to get work into the pipeline
  sleep 1
  collection.crawler_kill
  collection.enqueue_xml(enqueue_data)
  msg "Pushed more data"
end

collection.wait_until_idle
collection.full_merge
collection.wait_until_idle

xml = collection.xml

def content_count(index_node, name)
  content_node = index_node.xpath("vse-index-content[@name='#{name}']").first
  if content_node
    content_node['n'].to_i
  else
    0                           # Not found means a count of zero.
  end
end

index_node = xml.xpath("//vse-index-file").first
max_docid = index_node['max-docid'].to_i
doc_count = content_count(index_node, 'doc#')
delete_count = content_count(index_node, 'del#')

results.add_equals(999, max_docid, "maximum doc id")
results.add_equals(1000, doc_count, "document count")
results.add_equals(0, delete_count, "delete reference count")

results.cleanup_and_exit!
