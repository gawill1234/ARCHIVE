#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/indexer/keep-acls'

require 'misc'
require 'collection'
require 'keep-acls'

url_xml_string = <<EOF
<crawl-urls>
  <crawl-url url="f" status="complete" synchronization="indexed">
    <crawl-data encoding="xml" content-type="application/vxml">
      <document vse-key="0">
        <content name="main" acl="acl1">data2</content>
      </document>
      <content name="added" acl="moreacl1" add-to="0">moredata</content>
    </crawl-data>
  </crawl-url>
</crawl-urls
EOF
url_xml = Nokogiri::XML(url_xml_string).root

results = TestResults.new('Ensure contents added to a document save the correct rights')
results.need_system_report = false

collection = setup_collection(TESTENV.test_name, url_xml)
results.associate(collection)

ensure_acl_entries_are_saved_and_searchable(collection, url_xml, results)

results.cleanup_and_exit!(true)
