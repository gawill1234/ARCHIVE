# This creates simple crawl-urls with a small bit of text
class CrawlUrlCreator
  CRAWL_URL = <<-HERE
<crawl-urls synchronization="indexed-no-sync" >
  <crawl-url status="complete" url="http://lince/doc-%s-%d">
    <crawl-data content-type="text/plain" encoding="text">
      Nothing to see here in document %d in collection %s.
    </crawl-data>
  </crawl-url>
</crawl-urls>
HERE

  def create_enqueue_data(collection_name, document_index)
    CRAWL_URL % [collection_name, document_index, document_index, collection_name]
  end
end
