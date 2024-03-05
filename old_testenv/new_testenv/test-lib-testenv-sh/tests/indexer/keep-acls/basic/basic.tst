#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/keep-acls'

require 'misc'
require 'collection'
require 'keep-acls'

url_xml_string = <<EOF
<crawl-urls>
  <crawl-url url="a" status="complete">
    <crawl-data encoding="xml" content-type="application/vxml">
      <document>
        <content name="main" acl="acl1">data</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls
EOF
url_xml = Nokogiri::XML(url_xml_string).root

results = TestResults.new('Ensure that rights are saved to the index when keep-acls is enabled')
results.need_system_report = false

collection = setup_collection(TESTENV.test_name, url_xml)
results.associate(collection)

ensure_acl_entries_are_saved_and_searchable(collection, url_xml, results)

results.cleanup_and_exit!(true)
