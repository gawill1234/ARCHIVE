# multi-stream-indexing-helper

def multistream_setup(collection)
  vlog "Multistream: starting setup"
  c = Velocity::Collection.new(@vapi, collection)

  begin
    c.clean_crawl
    search_result = c.search("")
    search_result.to_s.should_not match(/.*id=\'SEARCH_ENGINE_EMPTY_INDEX\'.*/)
    search_result.xpath("//added-source/@status").to_s.should_not eql("connection-failed")
  rescue
    puts "Something is wrong with collection #{collection}. Did you download it from the qa namespace?"
  end

end

def confirm_num_results(collection, query, num_results)
  c = Velocity::Collection.new(@vapi, collection)
  search_result = c.search(query)
  total_results = search_result.xpath("//added-source/@total-results").empty? ? "0" : search_result.xpath("//added-source/@total-results").to_s
  search_result.xpath("//added-source/@total-results").to_s.should eql(num_results)
end

def confirm_vse_stream(collection, query, target_xpath, vse_stream_id)
  c = Velocity::Collection.new(@vapi, collection)
  search_result = c.search(query)
  search_result.xpath("#{target_xpath}/@vse-streams").to_s.should eql(vse_stream_id)
end

def confirm_content_text(collection, query, content_xpath, expected_value)
  c = Velocity::Collection.new(@vapi, collection)
  search_result = c.search(query)
  search_result.xpath("#{content_xpath}/text()").to_s.should eql(expected_value)
end

def confirm_language(collection, query, document_xpath, expected_language)
  confirm_content_text(collection, query, "#{document_xpath}/content[@name='language']", expected_language)
end