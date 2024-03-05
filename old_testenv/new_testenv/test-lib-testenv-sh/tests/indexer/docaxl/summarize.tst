#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/docaxl'

require 'misc'
require 'collection'

results = TestResults.new('Ensure vse:summarize can be called even when summarize-contents is empty')
results.need_system_report = false

contents_axl = <<EOF
<process-xsl><![CDATA[
  <xsl:variable name="doc" select="vse:document()" />
    <document>
      <xsl:copy-of select="$doc/@*|$doc/*" />
      <xsl:copy-of select="vse:contents()" />
      <xsl:copy-of select="vse:summarize()" />
    </document>
 ]]></process-xsl>
EOF

url_xml_string = <<EOF
<crawl-urls>
  <crawl-url url="a" status="complete" synchronization="indexed-no-sync">
    <crawl-data encoding="xml" content-type="application/vxml">
      <document>
        <content name="title">data</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls
EOF
url_xml = Nokogiri::XML(url_xml_string).root

# Set up collection
collection = Collection.new(TESTENV.test_name)
results.associate(collection)
collection.delete
collection.create('default-push')

# Set empty summarize-contents option
xml = collection.xml
set_option(xml, 'vse-index', 'vse-index-option', 'summarize-contents', '')
collection.set_xml(xml)

# Enqueue data
collection.enqueue_xml(url_xml)

# Search with Doc AXL containing vse:summarize()
res = collection.search('data', {:output_axl => contents_axl})

# Check that the document was successfully returned
documents = res.xpath('//document')
results.add_number_equals(1, documents.size, "document")

# Check that the title conent was successfully returned
contents = res.xpath("//content")
results.add_number_equals(1, contents.size, "content")

# Check that the vse:summarize() call was ignored and the snippet was not created
snippets = res.xpath("//content[@name='snippet']")
results.add_number_equals(0, snippets.size, "snippet")

results.cleanup_and_exit!(true)
