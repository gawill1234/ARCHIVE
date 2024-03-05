require 'collection'

def do_late_binding_http_basic_test(results, username, password)
  enqueue_xml = <<EOF
<crawl-url url="http://example.com/1" status="complete" synchronization="indexed">
  <crawl-data encoding="xml" content-type="application/vxml">
    <document authorization-url="http://testbed14.test.vivisimo.com/secure/">
      <content name="snippet" type="text">You found me!</content>
    </document>
  </crawl-data>
</crawl-url>
EOF
  enqueue_xml = Nokogiri::XML(enqueue_xml).root

  collection = Collection.new(TESTENV.test_name)
  results.associate(collection)
  collection.delete
  collection.create

  collection.enqueue_xml(enqueue_xml)

  msg('Make sure we do not get results when authentication is not provided (disabled due to bug #26134)')
  #search_results = collection.search
  #docs = search_results.xpath('//document')
  #results.add_number_equals(0, docs.length, 'document')

  msg('Make sure we do get results when authentication is provided')
  search_results = collection.search(nil, :authorization_username => username, :authorization_password => password)
  docs = search_results.xpath('//document')
  results.add_number_equals(1, docs.length, 'document')

  if (docs.length > 0)
    doc = docs.first
    contents = doc.xpath('content[@name="snippet"]')
    results.add_number_equals(1, contents.length, 'content')

    if (contents.length > 0)
      snippet = contents.first.content.strip
      results.add_equals("You found me!", snippet, 'snippet')
    end
  end
end
