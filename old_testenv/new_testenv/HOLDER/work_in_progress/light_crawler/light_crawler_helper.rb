def create_crawl_url_status(args=nil, logic="and", limit=nil, offset=nil)
  if args
    node_string = "<crawl-url-status"
    if limit
      node_string += " limit=\"#{limit}\""
    end
    if offset
      node_string += " offset=\"#{offset}\""
    end
    node_string += ">
      <crawl-url-status-filter-operation name=\"#{logic}\">"

    args.each {|ah|
      args_hash = Hash[*ah.map {|key, value|
                      [key, value]}.flatten]
      node_string+="<crawl-url-status-filter "

      args_hash.each {|key, value|
        node_string += "#{key}=\"#{value}\" "
      }
      node_string += "/>"

    }
    node_string += "</crawl-url-status-filter-operation>
      </crawl-url-status>"
    Nokogiri::XML(node_string)
  end
end

def get_url(document_key)
  od = @original_data[document_key]
  ad = @additional_data[document_key]
  if !od.nil?
    od.xpath("//crawl-url/@url").to_s
  elsif !ad.nil?
    ad.xpath("//crawl-url/@url").to_s
  else
    nil
  end
end

def get_time(collection, document_key)
  input = create_crawl_url_status([{:name => "url", :comparison => "eq", :value => get_url(document_key)}])
  status = status_query(collection, input)

  if !status.xpath("//crawl-url/@at").empty?
    dt = status.xpath("//crawl-url/@at").to_s
  elsif !status.xpath("//crawl-url/@recorded-at").empty?
    dt = status.xpath("//crawl-url/@recorded-at").to_s
  else
    return nil
  end

  Time.xmlschema(DateTime.strptime(dt, '%s'))

end

def get_xml(document_key)
  od = @original_data[document_key]
  ad = @additional_data[document_key]
  if !od.nil?
    od
  elsif !ad.nil?
    ad
  else
    nil
  end
end
def status_query(collection, input)
  @vapi.search_collection_url_status_query(:collection => collection, :crawl_url_status => input.root)
end

def crawl_url_count(predicate=nil)
  @status_query_result.xpath("//crawl-url#{predicate.nil? ? "" : "[" + predicate + "]"}").length
end

def error_count(predicate=nil)
  @status_query_result.xpath("//error#{predicate.nil? ? "" : "[" + predicate + "]"}").length
end

def status_of(document_key)
  @status_query_result.xpath("//crawl-url[@url='#{get_url(document_key)}']/@status").to_s
end

def error_id(document_key)
  @status_query_result.xpath("//crawl-url[@url='#{get_url(document_key)}']//error[1]/@id").to_s
end

def get_status_node(document_key)
  @status_query_result.xpath("//crawl-url[@url='#{get_url(document_key)}']")
end

def light_crawler_enqueue_url(name, document_key)
  response = @vapi.search_collection_enqueue({:collection => name, :crawl_urls => get_xml(document_key).root.to_s})
  #response.xpath("/crawler-service-enqueue-response/@n-success").to_s.should eql("1")
end

def light_crawler_delete_url(name, document_key)
  response = @vapi.search_collection_enqueue({:collection => name, :crawl_urls => "<crawl-delete url=\"#{get_url(document_key)}\" synchronization=\"indexed-no-sync\" />"})
  #response.xpath("/crawler-service-enqueue-response/@n-success").to_s.should eql("1")
end

def light_crawler_enqueue_xml(name, document_key)
  @vapi.search_collection_enqueue_xml({:collection => name, :crawl_nodes => get_xml(document_key).root.to_s})
end

def num_success
  @enqueue_response.xpath("//crawler-service-enqueue-response/@n-success").to_s.to_i
end

def num_failed
  @enqueue_response.xpath("//crawler-service-enqueue-response/@n-failed").to_s.to_i
end

def light_crawler_remove_fallback_converter(name)
  config = @vapi.search_collection_xml({:collection => name})
  
  config.xpath("//converters/converter[@type-in='vivisimo/fallback']").remove
  config.xpath("//converters/converter[@type-in='vivisimo/fallback']").should be_empty
  @vapi.search_collection_set_xml({:collection => name, :xml => config})
  @vapi.search_collection_update_configuration({:collection => name})

end

def light_crawler_replace_fallback_converter(name)
  config = @vapi.search_collection_xml({:collection => name}) 
  fallback_converter = <<HERE
<converter type-in="vivisimo/fallback" type-out="application/vxml-unnormalized">
  <call-function name="vse-converter-unknown-to-vxml">
    <with name="extract-strings">no, output XML</with>
  </call-function>
</converter>
HERE
  config.xpath("/vse-collection/vse-config/converters").first.before fallback_converter

  @vapi.search_collection_set_xml({:collection => name, :xml => config})
  @vapi.search_collection_update_configuration({:collection => name})
end

def light_crawler_test_setup(name)
  #vlog "Setting up collection #{name}"
  collection = Velocity::Collection.new(@vapi, name)
  begin
    #vlog "Delete the collection"
    collection.delete
    #vlog "Collection deleted"
  rescue
    #vlog "Error in deleting collection"
  end

  begin
    collection.create(name.match(/-heavy$/) ? "default" : "default-push")
    #vlog "Collection created"
  rescue
    #vlog "Error in creating collection"
  end

  smb_config = <<HERE
      <crawl-extender type="crawl-seed">
        <call-function name="vse-crawler-seed-extender-java-common" no-view-resolved="no-view-resolved">
          <with name="protocol">smb</with>
          <with name="classname">com.vivisimo.connector.SMBConnector</with>
          <with name="dns">dns</with>
        </call-function>
      </crawl-extender>
HERE

  collection.add_seed(Nokogiri::XML(smb_config))
  #vlog "Added seed"

  enqueue_data(name, @original_data)
  #vlog "Enqueued original data"

  collection.wait_for_crawl("live", 1, true)
  #vlog "Done waiting for crawl"

end

def enqueue_data(name, data)
  data.each_key {|key| light_crawler_enqueue_url(name, key) }
end

def create_original_data
{
"url_manual" => Nokogiri::XML(<<HERE
<crawl-url url="http://manual-url.com/" status="complete">
  <crawl-data content-type="application/vxml">
    &lt;document content-type="application/vxml">
      &lt;content name="title">Manual URL&lt;/content>
      &lt;content name="snippet">This is a URL that should just work, no problems, that was manually specified&lt;/content>
    &lt;/document>
  </crawl-data>
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
  </curl-options>
</crawl-url>
HERE
),
"url_crawled" => Nokogiri::XML(<<HERE
<crawl-url url="smb://testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-2/doc/README">
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
    <curl-option name="user-password">\\gaw:mustang5</curl-option>
    <crawl-extender-option name="archive">false</crawl-extender-option>
  </curl-options>
</crawl-url>
HERE
),
"url_error_nonexistent" => Nokogiri::XML(<<HERE
<crawl-url url="file:///no-such-file">
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
  </curl-options>
</crawl-url>
HERE
),
"url_error_no_permissions" => Nokogiri::XML(<<HERE
<crawl-url url="smb://testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-2/doc/noperm/">
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
    <curl-option name="user-password">\\gaw:mustang5</curl-option>
    <crawl-extender-option name="archive">false</crawl-extender-option>
  </curl-options>
</crawl-url>
HERE
),
"url_to_be_deleted" => Nokogiri::XML(<<HERE
<crawl-url url="smb://testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-2/doc/thing.txt">
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
    <curl-option name="user-password">\\gaw:mustang5</curl-option>
    <crawl-extender-option name="archive">false</crawl-extender-option>
  </curl-options>
</crawl-url>
HERE
)}
end

def create_additional_data 
{
"url_takes_time_to_crawl" => Nokogiri::XML(<<HERE
<crawl-url url="smb://testbed5.test.vivisimo.com/testfiles/samba_test_data/samba-2/doc/SuSE-Linux-Adminguide-9.2.pdf">
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
    <curl-option name="user-password">\\gaw:mustang5</curl-option>
    <crawl-extender-option name="archive">false</crawl-extender-option>
  </curl-options>
</crawl-url>
HERE
),
"url_warning" => Nokogiri::XML(<<HERE
<crawl-url url="http://manual-url.com/failure" status="complete">
  <crawl-data content-type="application/vxml">
    &lt;document content-type="application/vxml">
      &lt;content name="title">Manual URL with warning&lt;/content>
      &lt;content name="snippet">This is a URL that should work, but have a warning, that was manually specified&lt;/content>
    &lt;/document>
  </crawl-data>
  <crawl-data />
  <curl-options>
    <curl-option name="default-allow">allow</curl-option>
  </curl-options>
</crawl-url>
HERE
),
"url_1" => Nokogiri::XML(<<HERE
<crawl-urls>
  <crawl-url url="1" status="complete">
    <crawl-data synchronization="indexed" content-type="application/vxml">
      &lt;document>
        &lt;content name="title">1&lt;/content>
      &lt;/document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
HERE
)}
end
