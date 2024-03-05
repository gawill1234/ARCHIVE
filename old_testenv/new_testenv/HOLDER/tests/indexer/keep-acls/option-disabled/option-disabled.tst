#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/keep-acls'

require 'misc'
require 'collection'
require 'keep-acls'

url_xml_string = <<EOF
<crawl-urls>
  <crawl-url url="a" status="complete" synchronization="indexed">
    <crawl-data encoding="xml" content-type="application/vxml">
      <document>
        <content name="main" acl="acl1">data</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls
EOF
url_xml = Nokogiri::XML(url_xml_string).root

results = TestResults.new("Ensure that the index format doesn't change if the keep-acls option is disabled")
results.need_system_report = false

collection = setup_collection(TESTENV.test_name, url_xml, :keep_acls => false)
results.associate(collection)
ensure_index_files_are_equal(collection, results)
ensure_acl_attributes_are_equal(collection, [nil], results)

results.cleanup_and_exit!(true)
