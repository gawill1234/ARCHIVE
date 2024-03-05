def prepare_crawl(collection)
  vlog "Ensuring collection #{collection} is running"
  c = Velocity::Collection.new(@vapi, collection)
  c.clean_crawl
  search_result = c.search("")
  search_result.to_s.should_not match(/.*id=\'SEARCH_ENGINE_EMPTY_INDEX\'.*/)
  search_result.xpath("//added-source/@status").to_s.should_not eql("connection-failed")
end
