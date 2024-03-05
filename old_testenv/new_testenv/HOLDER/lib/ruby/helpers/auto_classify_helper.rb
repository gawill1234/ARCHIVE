
def count_metas
  xml = @vapi.search_collection_xml({:collection => "auto-classify"})
  "num vse_metas: #{xml.xpath("//vse-meta/vse-meta-info").length}"
end


def auto_classify_test_setup(data_collection, project, display, ac_collection, annotation_name, other_annotation_name, num_hops)
  project_xml = Nokogiri::XML "<options name=\"#{project}\" load-options=\"core\">
                                <load-options name=\"core\" />
                                <set-var name=\"render.function\">#{display}</set-var>
                                <set-var name=\"render.sources\">#{data_collection}</set-var>
                                <set-var name=\"query.sources\">#{data_collection}</set-var>
                              </options>"
  begin
    @vapi.repository_add({:node => project_xml.root})
  rescue
    #node already exists, overwrite
    @vapi.repository_update({:node => project_xml.root})
  end
  display_xml = Nokogiri::XML "<function name=\"#{display}\" type=\"display\">
                                <prototype />
                                <call-function name=\"velocity-display\" />
                                <call-function name=\"auto-classify-link\" />
                                <call-function name=\"express-tagging\" />
                                <settings>
                                  <setting name=\"keyword-name\"
                                           group-id=\"1252952030-Sq6H3ghDZzfQ\" 
                                           group=\"tags\"
                                           from=\"core-annotation\">#{annotation_name}</setting>
                                  <setting name=\"keyword-permission-scheme\"
                                           group-id=\"1252952030-Sq6H3ghDZzfQ\"
                                           group=\"tags\" 
                                           from=\"core-annotation\">no-acls</setting>
                                  <setting name=\"keyword-name\"
                                           group-id=\"1252952031-Sq6H3ghDZ222\" 
                                           group=\"tags\"
                                           from=\"core-annotation\">#{other_annotation_name}</setting>
                                  <setting name=\"keyword-permission-scheme\"
                                           group-id=\"1252952031-Sq6H3ghDZ222\"
                                           group=\"tags\" 
                                           from=\"core-annotation\">no-acls</setting>
                                </settings>
                              </function>"
  begin
    @vapi.repository_add({:node => display_xml.root})
  rescue
    #node already exists, overwrite
    @vapi.repository_update({:node => display_xml.root})
  end

  ac = Velocity::Collection.new(@vapi, ac_collection)
  dc = Velocity::Collection.new(@vapi, data_collection)


  vlog("make sure auto-classify has the taxonomy converter")
  taxonomy_converter = Nokogiri::XML "<converter type-out=\"application/vxml\" type-in=\"ca-taxonomy\">
                                        <call-function name=\"vse-converter-taxonomy-to-auto-classify\">
                                          <with name=\"xpath-to-record\">/taxonomy/entity</with>
                                          <with name=\"xpath-to-label\">@name</with>
                                          <with name=\"xpath-to-query\">@query</with>
                                          <with name=\"xpath-to-nested\">entity</with>
                                          <with name=\"xpath-to-id\">@id</with>
                                          <with name=\"inherit-queries\">true</with>
                                        </call-function>
                                      </converter>"
  vlog("taxonomy converter created")

  ac.add_converter(taxonomy_converter)

  vlog("make sure auto-classify is empty")
  ac.clean
  ac.search("").xpath("/query-results/added-source/log/error/@id").to_s.should eql("SEARCH_ENGINE_EMPTY_INDEX")

  reset_data_collection(data_collection, project, annotation_name, num_hops)
end

def reset_data_collection(data_collection, project, annotation_name, num_hops="1")
  vlog("reset the data collection")
  dc = Velocity::Collection.new(@vapi, data_collection)
  begin
   dc.delete
  rescue
    #doesnt exist, this is fine
  end
  dc.create

  ds = Velocity::Source.new(@vapi, data_collection)
  random_sort = Nokogiri::XML "<with name=\"fi-sort\">random|$score * (1 - math:random() + <value-of select=\"math:random()\" /> div 100)</with>"
  ds.add_vse_form_with(random_sort)

  vlog("remove any express tagging operations")
  admin_login
  page.open "#{@query_meta}?v:sources=#{data_collection}&v:frame=express-annotate&v:project=#{project}&view=1"
  page.wait_for_page_to_load(10000)

  begin
    page.click "link=Cancel/Dismiss All"
    sleep 2
    page.click "//div[@id='delete-pending-express-dialog']//div[@class='buttons']/span[1]"
    page.wait_for_page_to_load(10000)
  rescue
    # no express tagging operations, this is fine
  end
  page.get_text("id=document-list").should =~ /There are no pending Express Tagging operations/

  vlog("kill the indexer since we just queried the collection")
  begin
    dc.stop_index
  rescue
  end

  vlog("add the first seed")
  original_seed = Nokogiri::XML "<call-function name=\"vse-crawler-seed-urls\" type=\"crawl-seed\"><with name=\"urls\">http://vivisimo.com</with><with name=\"hops\">#{num_hops}</with></call-function>"
  dc.add_seed(original_seed)
      
  vlog("add the binning config for ease of viewing the tags")
  binning_config = Nokogiri::XML "<binning-set><call-function name=\"binning-set\"><with name=\"select\">$#{annotation_name}</with><with name=\"label\">Tags</with><with name=\"bs-id\">tags</with></call-function><binning-tree><call-function name=\"binning-tree\" /></binning-tree></binning-set>"
  dc.add_binning_set(binning_config)

  vlog("crawl")
  dc.start_crawl

  vlog("make sure vivi-site is not empty now")
  dc_search_result = dc.search("")
  dc_search_result.xpath("/query-results/log/error/@id").should be_empty

  vlog("make sure vivi-site has results")
  (dc_search_result.xpath("/query-results/added-source/@total-results").to_s.to_i > 0).should be_true
end

def create_classification_set(classification_set_name, data_collection, project)
  admin_login
  page.open "#{@velocity}?v.app=auto-classify"
  page.type("id=step1datacollection", classification_set_name)
  page.type("id=step1vsources", data_collection)
  page.type("id=step1vproject", project)
  page.click("id=accc-button")
  sleep 10
  page.get_text("id=success-done").should =~ /Your classification has been saved\./
  page.click("link=Return to the configuration screen")
  sleep 10
end


def import_taxonomy(classification_set_name, data_collection, project, taxonomy_url)

  vlog("import the taxonomy into auto-classify")
  dc = Velocity::Collection.new(@vapi, data_collection)
  admin_login
  page.open "#{@velocity}?v.app=auto-classify&data-collection=#{classification_set_name}&data-sources=#{data_collection}&v:project=#{project}&config=1"

  page.click("id=which-taxonomy")
  page.is_editable("id=taxonomy-url").should be_true
  # if this is false, that means the classification set does not exist

  page.type("id=taxonomy-url", taxonomy_url)
  page.type("id=taxonomy-format", "xml")
  page.click("id=act-button")
  sleep 5
  page.get_text("id=success-done").should =~ /Taxonomy import started/

  page.click("link=See the progress here")
  page.wait_for_page_to_load(10000)
  if !page.is_element_present("//div[@id='viv-sidebar']//div[@id='ac-binning']//ul[@id='collection-path-label1']/li[@id='root-label']/div[@id='root-label-children']//div[@class='label clearfix']/a[@class='folder']")
    sleep 15
    page.refresh
    if !page.is_element_present("//div[@id='viv-sidebar']//div[@id='ac-binning']//ul[@id='collection-path-label1']/li[@id='root-label']/div[@id='root-label-children']//div[@class='label clearfix']/a[@class='folder']")
      sleep 15
      page.refresh
    end
  end
  page.is_element_present("//div[@id='viv-sidebar']//div[@id='ac-binning']//ul[@id='collection-path-label1']/li[@id='root-label']/div[@id='root-label-children']//div[@class='label clearfix']/a[@class='folder']").should be_true
  page.is_element_present("//div[@id='document-list']/ol/li[contains(@class, 'document')]").should be_true

end

def express_tag(classification_set_name, data_collection, project, annotation_name)

  vlog("Express tag the results")
  dc = Velocity::Collection.new(@vapi, data_collection)
  admin_login
  page.open "#{@velocity}?v.app=auto-classify&data-collection=#{classification_set_name}&data-sources=#{data_collection}&v:project=#{project}&config=1"

  page.is_editable("id=annotation-name").should be_true
  # if this is false, that means the classification set does not exist or does not have any classes

  page.click("//form[@id='ac-config-tagging-form']//input[@name='data-sources']")
  page.type("id=annotation-name", annotation_name)
  page.click("//form[@id='ac-config-tagging-form']//span[@id='act-button']")
  sleep 10
  page.get_text("id=success-done").should =~ /Success - Express tagging of the categories started/

  page.click("link=check tagging status")
  page.wait_for_page_to_load(10000)
  sleep 15
  vlog("check to make sure all the tags are done")
  page.is_element_present("//div[@id='document-list']/table//tr[@class='viv-tagging-checking']").should be_false

  vlog("check to see that all the results have at least one tag")
  (dc.search("NOT CONTENT #{annotation_name}").xpath("/query-results/added-source/@total-results").to_s).to_i.should eql(0)

end