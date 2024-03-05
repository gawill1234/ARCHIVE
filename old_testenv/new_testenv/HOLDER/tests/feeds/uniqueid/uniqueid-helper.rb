def enqueue_url_with_multiple_crawl_datas
  crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy-multiple-crawl-datas"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">First crawl data document</content></document>
      </crawl-data>
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Second crawl data document</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/multiple-docs-with-same-url-first"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document url="http://vivisimo.com/multiple-docs-with-same-url"><content name="description">First document</content></document>
      </crawl-data>
    </crawl-url>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/multiple-docs-with-same-url-second"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document url="http://vivisimo.com/multiple-docs-with-same-url"><content name="description">Second document</content></document>
      </crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

  @collection.enqueue_xml(crawl_nodes)
end

def check_documents(options = {})
  number = options[:number] || 1

  audit_log = @collection.audit_log_retrieve

  audit_log_entries = audit_log.xpath("//audit-log-entry/crawl-activity")

  count = audit_log_entries.count

  @test_results.add_number_equals(number, count, "audit log entry", :plural => "audit log entries")

  urls = Hash.new(0)
  audit_log_entries.each do | entry |
    unique_url = entry.xpath("@unique-url")
    @test_results.add_number_equals(1, unique_url.count, "unique url attribute")
    currenturl = unique_url.first.value
    urls[currenturl] += 1
  end

  urls.each do | k, v |
    msg "Checking: '#{k}'"
    @test_results.add_number_equals(1, v, "occurance")
  end
end
