#todo: parametrize folder label, folder permission scheme, take unlimited # of folder settings
  def test_setup (project, display, collection, ics_collection, folder_annotation_1, folder_annotation_2, folder_annotation_3, use_acls=false)
    vlog "Folders: starting setup"
    project_xml = Nokogiri::XML "<options name=\"#{project}\" load-options=\"core\">
                                  <load-options name=\"core\" />
                                  <set-var name=\"render.function\">#{display}</set-var>
                                  <set-var name=\"render.sources\">#{collection}</set-var>
                                  <set-var name=\"query.sources\">#{collection}</set-var>
                                  <set-var name=\"ics-collection\">#{ics_collection}</set-var>
                                </options>"
    begin
      @vapi.repository_delete({:element => "options", :name => project})
    rescue
    end
    begin
      @vapi.repository_add({:node => project_xml.root})
    rescue
    end
    display_xml = Nokogiri::XML "<function name=\"#{display}\" type=\"display\">
                                  <prototype />
                                  <call-function name=\"velocity-display\" />
                                  <call-function name=\"express-tagging\" />
                                  <settings>
                                    <setting name=\"annotation-query-saving\" from=\"core-annotation-folders\">true</setting>


                                    <setting name=\"folder-name\" group-id=\"1\" group=\"folders\" from=\"core-annotation-folders\">#{folder_annotation_1}</setting>
                                    <setting name=\"folder-label\" group-id=\"1\" group=\"folders\" from=\"core-annotation-folders\">Folders</setting>
                                    <setting name=\"folders-permission-scheme\" group-id=\"1\" group=\"folders\" from=\"core-annotation-folders\">no-acls</setting>

                                    <setting name=\"folder-name\" group-id=\"2\" group=\"folders\" from=\"core-annotation-folders\">#{folder_annotation_2}</setting>
                                    <setting name=\"folder-label\" group-id=\"2\" group=\"folders\" from=\"core-annotation-folders\">Folders</setting>
                                    <setting name=\"folders-permission-scheme\" group-id=\"2\" group=\"folders\" from=\"core-annotation-folders\">public</setting>

                                    <setting name=\"folder-name\" group-id=\"3\" group=\"folders\" from=\"core-annotation-folders\">#{folder_annotation_3}</setting>
                                    <setting name=\"folder-label\" group-id=\"3\" group=\"folders\" from=\"core-annotation-folders\">Folders</setting>
                                    <setting name=\"folders-permission-scheme\" group-id=\"3\" group=\"folders\" from=\"core-annotation-folders\">private</setting>
                                  </settings>
                                </function>"
    begin
      @vapi.repository_delete({:element => "function", :name => display})
    rescue
    end
    begin
      @vapi.repository_add({:node => display_xml.root})
    rescue
    end

    icsc = Velocity::Collection.new(@vapi, ics_collection)
    vlog "Collection object created"
    begin
      vlog "Delete ics begin"
      icsc.delete
      vlog "Deleted ics collection"
    rescue
      #doesnt exist
    end
    icsc.create('ics-default')
    vlog "Created ics collection"

    begin
      @vapi.repository_delete({:element => 'source', :name => ics_collection})
      vlog "Deleted source"
    rescue
      #doesnt exist
    end
    icss_xml = Nokogiri::XML "<source name=\"#{ics_collection}\" type=\"ref\">
                               <add-sources names=\"ics-default-source\">
                                 <with name=\"collection\">#{ics_collection}</with>
                                 <with name=\"uses-acls\">#{use_acls}</with>
                               </add-sources>
                               <tests />
                               <help />
                               <description />
                             </source>"
    begin
      @vapi.repository_add({:node => icss_xml.root})
      vlog "Added source to repository"
    rescue
      #node already exists, overwrite
      @vapi.repository_update({:node => icss_xml.root})
      vlog "Updated source in repository"
    end


    dc = Velocity::Collection.new(@vapi, collection)
    begin
      dc.delete
      vlog "Reset the data collection"
    rescue
      #doesnt exist
    end
    dc.create
    original_seed = Nokogiri::XML "<call-function name=\"vse-crawler-seed-urls\" type=\"crawl-seed\"><with name=\"urls\">http://vivisimo.com</with><with name=\"hops\">1</with></call-function>"
    dc.add_seed(original_seed)

    acl_curl_option = Nokogiri::XML "<curl-option name=\"default-acl\">v.everyone</curl-option>"
    dc.add_curl_option(acl_curl_option)

    vlog "Crawling the data collection"
    dc.start_crawl
    dc_search_result = dc.search("")

    vlog "Make sure data collection is not empty now"
    dc_search_result.to_s.should_not match(/.*id=\'SEARCH_ENGINE_EMPTY_INDEX\'.*/)

    form_component = Nokogiri::XML("<call-function name=\"shared-folder-input\" />")
    s = Velocity::Source.new(@vapi, collection)
    s.add_form_component(form_component)

  end  

  def id_of(folder_text)
    folder_text.gsub(' ', '-').gsub('"', '').gsub("'", "")
  end

  def save_folder(project, collection, folder_annotation, folder_label)
    vlog "Saving a new folder"
    page.open "#{@query_meta}?v:sources=#{collection}&v:project=#{project}"
    page.click "id=viv-folder-new-link-#{folder_annotation}"
    page.type("id=viv-folder-new-input-#{folder_annotation}", folder_label)
    page.click "//li[@id='viv-folder-new-#{folder_annotation}']//span[@class='button' and .//span/text()='OK']"
    sleep 5
    folder_id = "viv-folder-#{folder_annotation}-#{id_of(folder_label)}"
    vlog "folder_id == " + folder_id
    page.is_element_present("id=#{folder_id}").should be_true
  end

  def save_results(project, collection, folder_annotation, folder_label, doc_ids=nil)
    vlog "Saving a new folder"
    page.open "#{@query_meta}?v:sources=#{collection}&v:project=#{project}"
    if doc_ids
      doc_ids.split(",").each{|docid|
        page.click "id=inp-#{docid.gsub("Ndoc", "")}"
      }
    else
      page.click "id=sel-all-top" 
    end
    page.click "id=export-menu-button"
    page.click "id=folders-save-menu-item"
    sleep 3
    page.click "id=#{folder_annotation}||#{id_of(folder_label)}"
    page.click "id=viv-nav-folders-save"
    sleep 10
    page.get_text("//div[@id='folder-dialog']/div[@class='bd']/div[@class='viv-success']/").should =~ /Successfully added to folder/
    vlog "Checking results for saving documents into folder"
    page.click "link=See updated results."
    page.wait_for_page_to_load(10000)
    page.get_text("//ol[@class='results']/li[@class='document source-#{collection}']").should =~ /In Folders: .*#{folder_label}/
  end

  def save_query(project, collection, ics_collection, folder_annotation, folder_label, query)
    vlog "Saving the current query"
    page.open "#{@query_meta}?v:sources=#{collection}&v:project=#{project}&query=#{query}"
    page.click "id=save-query-button"
    sleep 5
    annotation_array = "#{folder_annotation},".split(",")
    label_array = "#{folder_label},".split(",")
    annotation_array.each_index {|x|
      page.click "id=#{annotation_array[x]}||#{id_of(label_array[x])}"
    }
    page.click "id=viv-nav-folders-save"
    sleep 10
    page.get_text("//div[@id='folder-dialog']/div[@class='bd']/div[@class='viv-success']/").should =~ /Successfully saved the query/

    # check that the query is in the list of results
    vlog "Checking results for saved query"
    page.click "link=See updated results."
    page.wait_for_page_to_load(10000)
    page.get_text("//ol[@class='results']/li[@class='document source-#{ics_collection}']").should =~ /Query: #{query}/
    label_array.each do |i|
      page.get_text("//ol[@class='results']/li[@class='document source-#{ics_collection}']").should =~ /In Folders: .*#{i}/
    end
  end

  def is_in_folder?(project, collection, folder_annotation, folder_label, criteria)
    page.open "#{@query_meta}?v:sources=#{collection}&v:project=#{project}"
    page.wait_for_page_to_load(10000)
    page.click "id=viv-folder-label-#{folder_annotation}-#{id_of(folder_label)}"
    page.wait_for_page_to_load(10000)
    page.is_element_present(criteria)
  end

  def delete_query(project, collection, ics_collection, query)
    vlog "Deleting the query"
    page.open "#{@query_meta}?v:sources=#{collection}&v:project=#{project}&query=#{query} query WITHIN CONTENT type"
    page.wait_for_page_to_load(10000)
    page.click "//ol[@class='results']/li[@class='document source-#{ics_collection}']/div[contains(@class, 'document-header') and a[@class='title']]/span[@class='document-actions']/a[span/text()='delete query']"
# and text()=concat('Query: ', '#{query}')
    sleep 10
    # confirm that it's gone immediately
    page.is_element_present("//ol[@class='results']/li[@class='document source-#{ics_collection}']").should be_false

    # confirm the delete message
    page.get_text("//div[@id='document-list']/div[@class='viv-query-deleted']").should match(/Deleted saved query./)
    
# confirm that the saved query is gone on page reload
    page.open "#{@query_meta}?v:sources=#{collection}&v:project=#{project}&query=#{query} query WITHIN CONTENT type"
    page.wait_for_page_to_load(10000)
    (page.is_element_present("//ol[@class='results']/li[@class='document source-#{ics_collection}']") && page.get_text("//ol[@class='results']/li[@class='document source-#{ics_collection}']").match(/Query: #{query}/)).should be_false
  end