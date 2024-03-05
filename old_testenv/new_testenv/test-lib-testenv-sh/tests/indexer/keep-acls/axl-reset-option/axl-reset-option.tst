#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/keep-acls'

require 'misc'
require 'collection'
require 'keep-acls'

url_xml_string = <<EOF
<crawl-urls>
  <crawl-url url="a" status="complete" synchronization="indexed-no-sync">
    <crawl-data encoding="xml" content-type="application/vxml">
      <document>
        <content name="title" acl="acl1">data</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls
EOF
url_xml = Nokogiri::XML(url_xml_string).root

results = TestResults.new('Ensure that the output-acls option is correctly reset between multiple doc-axl functions')
results.need_system_report = false

collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create('default-push')

collection.set_index_options(:output_acls => false)

collection.enqueue_xml(url_xml)

contents_axl = <<EOF
<document>
  <attribute name="vse-doc-hash">
    <value-of select="vse:doc-hash()" />
  </attribute>
  <copy-of select="vse:contents()" />
  <copy-of select="vse:xml(vse:current-result(), true(), true())" />
  <copy-of select="vse:contents()" />
</document>
EOF

res = collection.search('data', :output_axl => contents_axl)
contents = res.xpath('//content')

results.add_number_equals(3, contents.size, 'content node')

results.add_equals(nil,    contents[0]['acl'], 'acl attribute')
results.add_equals('acl1', contents[1]['acl'], 'acl attribute')
results.add_equals(nil,    contents[2]['acl'], 'acl attribute')

results.cleanup_and_exit!(true)
