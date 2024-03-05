def check_documents(options = {})
  number = options[:number] || 1

  audit_log = @collection.audit_log_retrieve

  audit_log_entries = audit_log.xpath("//audit-log-entry/crawl-activity")

  count = audit_log_entries.count

  @test_results.add_number_equals(number, count, "audit log entry", :plural => "audit log entries")

  audit_log_entries.each do | entry |
    log_description = entry.xpath("always/content[@name='description']").first.text
    msg "Matching log entry: '#{log_description}'"

    doc_hash = entry.xpath("@document-key-hash")
    @test_results.add_number_equals(1, doc_hash.count, "document hash")

    query = "DOCUMENT_KEY_HASH:" + doc_hash.text;
    response = @collection.search(query)
    document = response.xpath("//document")
    document_count = document.count
    @test_results.add_number_equals(1, document_count, "document")
    description = document.xpath("content[@name='description' and text()='#{log_description}']")
    @test_results.add_number_equals(1, description.count, "description content")
  end
end
