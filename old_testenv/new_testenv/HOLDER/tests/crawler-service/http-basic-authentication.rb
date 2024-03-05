require 'collection'

def do_http_basic_auth_test(results, username, password)
  seed_xml = <<EOF
<call-function name="vse-crawler-seed-authenticated-urls" type="crawl-seed">
  <with name="urls">http://testbed14.test.vivisimo.com/secure/</with>
  <with name="username"></with>
  <with name="password"></with>
  <with name="hops">1</with>
</call-function>
EOF
  seed_xml = Nokogiri::XML(seed_xml).root

  seed_xml.xpath('//with[@name="username"]').first.content = username
  seed_xml.xpath('//with[@name="password"]').first.content = password

  collection = Collection.new(TESTENV.test_name)
  results.associate(collection)
  collection.delete
  collection.create

  conf = collection.xml
  crawler_conf = conf.xpath('//crawler').first
  crawler_conf << seed_xml
  collection.set_xml(conf)

  collection.crawler_start
  collection.wait_until_idle
  search_results = collection.search()

  docs = search_results.xpath('//document')
  results.add_number_equals(1, docs.length, 'document')

  if docs.size > 0
    doc = docs.first
    snippet = doc.xpath('content[@name="snippet"]').first.content.strip
    results.add_equals("<h1>You found me!</h1>", snippet, 'snippet')
  end
end
