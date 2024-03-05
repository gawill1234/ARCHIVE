#!/usr/bin/env ruby

require 'misc'
require 'collection'

def disable_light_crawler(c)
  conf = c.xml
  lcrawler = conf.xpath('//vse-config/crawler/call-function[@name="vse-crawler-light-crawler"]').unlink
  c.set_xml(conf)
end

def wrap(stuff)
  '<crawl-urls synchronization="indexed-no-sync" >%s</crawl-urls>' % stuff
end

results = TestResults.new('Enqueue URLs with parents set to create a simple ',
                          'graph and ensure that deleting the root will ',
                          'delete everything. ')

URLS_COUNT = 4
urls = ['a', 'b', 'c', 'd']
parents = ['d', 'a', 'a', 'c']

CRAWL_URL = '
<crawl-url url="%s" parent-url="%s" synchronization="indexed" status="complete">
   <crawl-data content-type="application/vxml" encoding="xml">
      <document><content name="foo">bar</content></document>
   </crawl-data>
</crawl-url>'

CRAWL_DELETE = '
<crawl-delete url="a" synchronization="indexed" recursive="recursive"/>'

CRAWL_DELETE_VSE_KEY = '
<crawl-delete vse-key="this_should_fail" synchronization="indexed" recursive="recursive" />'

c = Collection.new('del_recursive_basic')
results.associate(c)
c.delete
c.create
disable_light_crawler(c)
c.crawler_start
c.indexer_start
msg "Collection #{c.name} configured and started."

crawl_nodes = wrap((0...URLS_COUNT).map {|i| CRAWL_URL % [urls[i], parents[i]]}.join())
results.add(c.enqueue_xml(crawl_nodes), "#{URLS_COUNT} documents indexed.")

doc_count = c.index_n_docs
results.add(
            doc_count == URLS_COUNT,
            "#{doc_count} documents found in index.",
            "#{doc_count} documents found in index, expected #{URLS_COUNT}."
            )

begin
  c.enqueue_xml(wrap(CRAWL_DELETE_VSE_KEY))
  results.add(false,
              "Recursive vse-key delete enqueued successfully.")
rescue
  results.add(true,
              "Recursive vse-key delete failed to enqueue.")
end

results.add(
            c.enqueue_xml(wrap(CRAWL_DELETE)),
            "Successfully enqueued recursive delete for root node.",
            "Failed to enqueue recursive delete for root node."
            )

while ! c.indexer_idle? and ! c.crawler_idle?
  sleep 1
end

doc_count = c.index_n_docs
results.add(doc_count == 0,
            "#{doc_count} found in index. Successfully deleted all URLs.",
            "#{doc_count} found in index, failed to delete entire graph.")

results.cleanup_and_exit!
