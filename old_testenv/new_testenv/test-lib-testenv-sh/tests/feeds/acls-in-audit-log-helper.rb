def setup
  crawl_nodes = <<-HERE
  <crawl-urls>
    <crawl-url enqueue-type="reenqueued"
               status="complete"
               synchronization="indexed-no-sync"
               url="http://vivisimo.com/dummy">
      <crawl-data content-type="text/plain" encoding="text" acl="+corp\\user1">Nothing to see here.</crawl-data>
    </crawl-url>
  </crawl-urls>
  HERE

  msg "Setup"
  @test_results.associate(@collection)
  @collection.delete
  @collection.create
  # turn on activity feed converter
  # turn on cache content types
  # turn off 'remove logged input upon completion'
  @collection.set_crawl_options({ :activity_feed   => 'activity-feed',
                                  :cache_types     => "text/html text/plain text/xml application/vxml-unnormalized application/vxml",
                                  :purge_input_xml => "false" },
                                [])
  # remove light crawler
  @collection.remove_config_at("//call-function[@name='vse-crawler-light-crawler']")
  # add activity feed converter
  converter = <<-HERE
  <converter type-out="application/vxml" type-in="application/vactivity">
    <call-function name="vse-converter-activity-feed">
      <with name="retrieve">title
filetype
always</with>
      <with name="diff">snippet
size
diff</with>
    </call-function>
  </converter>
  HERE
  @collection.add_converter(converter)
  @collection.enqueue_xml(crawl_nodes)
end

def update_document(options = {})
  snippet = options[:snippet] || "Nothing to see here."
  acl     = options[:acl]     || "+corp\\user1"
  crawl_nodes = <<-HERE
    <crawl-urls>
      <crawl-url enqueue-type="reenqueued"
                 status="complete"
                 synchronization="indexed-no-sync"
                 url="http://vivisimo.com/dummy">
        <crawl-data content-type="text/plain" encoding="text" acl="#{acl}">#{snippet}</crawl-data>
      </crawl-url>
    </crawl-urls>
  HERE
  @collection.enqueue_xml(crawl_nodes)
end

def delete_document
  crawl_nodes = <<-HERE
    <crawl-urls synchronization="indexed">
      <crawl-delete url="http://vivisimo.com/dummy" />
    </crawl-urls>
  HERE
  @collection.enqueue_xml(crawl_nodes)
end

def check_audit_log(options = {})
  entries = options[:entries] || 1
  changed = options[:changed] || []
  deleted = options[:deleted] || false
  snippet = options[:snippet] || "Nothing to see here."
  acl     = options[:acl]     || "+corp\\user1"

  audit_log = @collection.audit_log_retrieve
  xpath = "//audit-log-entry"
  count = audit_log.xpath(xpath).count
  @test_results.add(count == entries,
                   "Found #{entries} audit log #{count == 1 ? 'entry' : 'entries'}.",
                   "Expected #{entries} audit-log-entry nodes, got #{count}.")
  @test_results.add(audit_log.xpath(xpath).any?,
                   "There is an audit log entry.",
                   "No audit-log-entry nodes.")
  xpath = "//audit-log-entry[position() = last()]"
  if changed.size > 0
    xpath << "[crawl-activity/changes]"
    @test_results.add(audit_log.xpath(xpath).any?,
                      "with a <changes> node underneath",
                      "The last audit-log-entry does not have a <changes> node.")
    if changed.include?("snippet")
      xpath = check_snippet(audit_log, xpath, snippet)
    end
  elsif deleted
    xpath << "[crawl-activity/deleted]"
    @test_results.add(audit_log.xpath(xpath).any?,
                      "with a <deleted> node underneath",
                      "The last audit-log-entry does not have a <deleted> node.")
    xpath = check_snippet(audit_log, xpath, snippet)
  else
    xpath = check_snippet(audit_log, xpath, snippet)
  end
  xpath << "[@originator = 'v.activity_feeds']"
  @test_results.add(audit_log.xpath(xpath).any?,
                  "from the activity feed",
                  "Wrong @originator - should be 'v.activity_feeds'.")
  xpath << "[@status = 'successful']"
  @test_results.add(audit_log.xpath(xpath).any?,
                   "with a successful status",
                   "Wrong @status - should be 'successful'.")
  xpath << "/crawl-activity"
  @test_results.add(audit_log.xpath(xpath).any?,
                  "and crawl-activity",
                  "No crawl-activity nodes.")
  xpath << "[@vse-key = 'http://vivisimo.com:80/dummy/-0']"
  @test_results.add(audit_log.xpath(xpath).any?,
                  "with the right vse-key",
                  "Wrong @vse-key - should be 'http://vivisimo.com:80/dummy/-0'.")
  xpath << "[@acl = '#{acl}']"
  @test_results.add(audit_log.xpath(xpath).any?,
                  "and the right ACL. Final xpath: #{xpath}",
                  "Wrong @acl - should be '#{acl}'. Full XML of audit log is:\n#{audit_log}")
end

def check_snippet(audit_log, xpath, snippet)
  xpath << "[.//content[@name='snippet'] = '#{snippet}']"
  @test_results.add(audit_log.xpath(xpath).any?,
                   "with the correct snippet",
                   "The last audit-log-entry does not have the correct snippet. Snippet should be: #{snippet}")
  xpath
end

def enqueue_content_xml(url)
  crawl_nodes = <<-HERE
    <crawl-urls>
      <crawl-url status="complete"
                 synchronization="indexed"
                 url="#{url}"
                 default-acl="crawl-url">
        <crawl-data content-type="application/vxml-unnormalized" acl="crawl-data">
          &lt;document default-content-acl="document">
            &lt;content acl="content" name="always">This 'always' content has its own acl&lt;/content>
            &lt;content name="always">This 'always' content should inherit an acl&lt;/content>
            &lt;content acl="content" name="diff">This 'diff' content has its own acl&lt;/content>
            &lt;content name="diff">This 'diff' content should inherit an acl&lt;/content>
          &lt;/document>
        </crawl-data>
      </crawl-url>
    </crawl-urls>
  HERE
  @collection.enqueue_xml(crawl_nodes)
end

def check_content(options)
  audit_log     = options[:audit_log]
  text          = options[:explicit]  ? 'has its own acl' : 'inherit an acl'
  explicit_text = options[:explicit]  ? 'explicit' : 'inherited'
  always_text   = options[:always]    ? 'Always' : 'Diff'
  current_xpath = options[:xpath].dup

  if options[:always]
    current_xpath << "/always/content[contains(text(), '#{text}')]"
  else
    current_xpath << "/created/added/content[contains(text(), '#{text}')]"
  end
  @test_results.add(audit_log.xpath(current_xpath).any?,
                    "#{always_text} content with #{explicit_text} ACL is present",
                    "#{always_text} content with #{explicit_text} ACL is missing. XPath checked: #{current_xpath}")
  if options[:explicit]
    current_xpath << "[@acl = 'content']"
    @test_results.add(audit_log.xpath(current_xpath).any?,
                      "with the proper @acl",
                      "ACL is wrong for the #{always_text.downcase} content with an ACL.")
  else
    current_xpath << "[@acl]"
    @test_results.add(audit_log.xpath(current_xpath).empty?,
                      "without an @acl, as expected.",
                      "#{always_text} content with #{explicit_text} ACL has an unexpected @acl.")
  end
end

def check_content_acls
  url = 'http://vivisimo.com/dummy1'
  enqueue_content_xml(url)

  audit_log = @collection.audit_log_retrieve
  xpath = "//audit-log-entry/crawl-activity[@original-url = '#{url}']"
  @test_results.add(audit_log.xpath(xpath).any?,
                   "Found an audit log entry where content ACLs are the most specific.",
                   "No audit log entry for url: #{url}.")

  check_content(:audit_log => audit_log, :xpath => xpath, :explicit => true,  :always => true)
  check_content(:audit_log => audit_log, :xpath => xpath, :explicit => false, :always => true)
  check_content(:audit_log => audit_log, :xpath => xpath, :explicit => true,  :always => false)
  check_content(:audit_log => audit_log, :xpath => xpath, :explicit => false, :always => false)
end

def enqueue_xml_with_acl_level(url, level)
  crawl_nodes = <<-HERE
    <crawl-urls>
      <crawl-url status="complete"
                 synchronization="indexed"
                 url="#{url}"
                 default-acl="crawl-url">
        <crawl-data content-type="application/vxml-unnormalized"#{level == 'crawl-data' || level == 'document' ? ' acl="crawl-data"' : ''}>
          &lt;document#{level == 'document' ? ' default-content-acl="document"' : ''}>
            &lt;content name="always">always content is needed to make the activity feed do its thing&lt;/content>
            &lt;content name="diff">Some uninteresting text.&lt;/content>
          &lt;/document>
        </crawl-data>
      </crawl-url>
    </crawl-urls>
  HERE
  @collection.enqueue_xml(crawl_nodes)
  # useful debugging:
  # puts "level: #{level}"
  # puts "crawl_nodes:"
  # puts crawl_nodes
end

def check_acls(level)
  url = "http://vivisimo.com/dummy-#{level}"
  enqueue_xml_with_acl_level(url, level)

  audit_log = @collection.audit_log_retrieve
  xpath = "//audit-log-entry/crawl-activity[@original-url = '#{url}']"
  @test_results.add(audit_log.xpath(xpath).any?,
                    "Found an audit log entry where the #{level} ACL is the most specific.",
                    "No audit log entry for url: #{url}.")

  xpath << "[@acl='#{level}']"
  @test_results.add(audit_log.xpath(xpath).any?,
                   "ACL is the #{level} ACL",
                   "Wrong ACL on crawl-activity for #{url} - should be '#{level}'")
end

def method_missing(m, *args, &block)
  method = m.to_s.match(/check_(.*)_acls/)
  if method
    check_acls(method[1].gsub('_', '-'))
  else
    super(m, *args, &block)
  end
end