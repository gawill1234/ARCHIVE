def language_vars_test_setup(collection)
  vlog "Language project variables setup: make sure example-metadata is crawled and indexer is running"
  c = Velocity::Collection.new(@vapi, collection)
  c.clean_crawl
  search_result = c.search("")
  search_result.to_s.should_not match(/.*id=\'SEARCH_ENGINE_EMPTY_INDEX\'.*/)
  search_result.xpath("//added-source/@status").to_s.should_not eql("connection-failed")
end

# even better/faster, use api function to get XML w/o going thru query-meta and then parse the XML with nokogiri

def confirm_stem_and_stoplist_value(project, stem_expected_value, stoplist_expected_value)
  @qm.query_vxml('v:project' => project, :query => 'horse')            
  stem = @qm.vxml.xpath("/vce/option[@name='stem']").attr('value').value
  stoplist =  @qm.vxml.xpath("/vce/option[@name='stoplist']").attr('value').value
  vlog stem
  vlog stoplist
  stem.should eql(stem_expected_value) and
  stoplist.should eql(stoplist_expected_value)
end

def confirm_segmenter_stem_and_stoplist_value(project, segmenter_expected_value, stem_expected_value, stoplist_expected_value)
  @qm.query_vxml('v:project' => project, :query => 'horse')  
  seg = @qm.vxml.xpath("/vce/option[@name='segmenter']").attr('value').value
  stem = @qm.vxml.xpath("/vce/option[@name='stem']").attr('value').value
  stoplist =  @qm.vxml.xpath("/vce/option[@name='stoplist']").attr('value').value
  vlog seg
  vlog stem
  vlog stoplist
  seg.should eql(segmenter_expected_value) and
  stem.should eql(stem_expected_value) and
  stoplist.should eql(stoplist_expected_value)
end
