def enqueue_url_with_single_crawl_data_and_single_document(changes = {})
  crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">One document, one crawl-data #{changes[:document_change]}</content></document>
      </crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

  @collection.enqueue_xml(crawl_nodes)
end

def enqueue_url_with_single_crawl_data_and_multiple_documents(changes = {})
  crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy2"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <vce>
          <document><content name="description">Two documents, one crawl-data, first document #{changes[:first_document_change]}</content></document>
          <document><content name="description">Two documents, one crawl-data, second document #{changes[:second_document_change]}</content></document>
        </vce>
      </crawl-data>
    </crawl-url>
  </crawl-urls>
HERE

  @collection.enqueue_xml(crawl_nodes)
end

def enqueue_url_with_multiple_crawl_data(changes = {})
  crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy3"
               >
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Two documents, two crawl-data, first document #{changes[:first_document_change]}</content></document>
      </crawl-data>
      <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
        <document><content name="description">Two documents, two crawl-data, second document #{changes[:second_document_change]}</content></document>
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
end
