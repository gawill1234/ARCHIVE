def setup
  msg "Setup"
  @test_results.associate(@collection)
  @collection.delete
  @collection.create
end

def enable_activity_feed(type = 'all')
  # turn on activity feed converter
  # turn on cache content types
  # turn off 'remove logged input upon completion'
  @collection.set_crawl_options({ :activity_feed   => type,
                                  :cache_types     => "text/html text/plain text/xml application/vxml-unnormalized application/vxml",
                                  :purge_input_xml => "false" },
                                [])
  # remove light crawler
  @collection.remove_config_at("//call-function[@name='vse-crawler-light-crawler']")
  # add activity feed converter
  converter = <<-HERE
  <converter type-out="application/vxml" type-in="application/vactivity">
    <call-function name="vse-converter-activity-feed">
      <with name="retrieve">description</with>
      <with name="diff">description</with>
    </call-function>
  </converter>
  HERE
  @collection.add_converter(converter)
end

def purge_audit_log()
  audit_log = @collection.audit_log_retrieve
  token = audit_log.xpath("//audit-log-retrieve-response").first['token']
  until token.nil?
    @collection.audit_log_purge(token)
    audit_log = @collection.audit_log_retrieve
    token = audit_log.xpath("//audit-log-retrieve-response").first['token']
  end
end
