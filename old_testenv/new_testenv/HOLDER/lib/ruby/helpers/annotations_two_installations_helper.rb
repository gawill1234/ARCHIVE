
def annotations_two_installations_setup_frontend(api, frontend_source, frontend_ics, 
                                                       project, display, ics_url, 
                                                       ics_user, ics_pw, 
                                                       backend_collection, backend_ics,
                                                       backend_host, backend_port)

  create_project_and_display(api, project, display, frontend_source, frontend_ics, ics_url, ics_user, ics_pw)

  
  dc = Velocity::Source.new(api, frontend_source)
  begin
    dc.delete
  rescue
    #doesnt exist
  end

  dc.create
  dc.add_form_component(Nokogiri::XML("<call-function name=\"vse_form\" />"))
  dc.add_vse_form_with(Nokogiri::XML("<with name=\"collection\">#{backend_collection}</with>"))
  dc.add_vse_form_with(Nokogiri::XML("<with name=\"host\">#{backend_host}</with>"))
  dc.add_vse_form_with(Nokogiri::XML("<with name=\"port\">#{backend_port}</with>"))
  
  ics_xml = Nokogiri::XML "<source name=\"#{frontend_ics}\" type=\"ref\">
                             <add-sources names=\"ics-default-source\">
                               <with name=\"collection\">#{backend_ics}</with>
                               <with name=\"host\">#{backend_host}</with>
                               <with name=\"port\">#{backend_port}</with>
                               <with name=\"uses-acls\">false</with>
                             </add-sources>
                             <tests />
                             <help />
                             <description />
                           </source>"
  begin
    api.repository_add({:node => ics_xml.root})
  rescue
    #node already exists, overwrite
    api.repository_update({:node => ics_xml.root})
  end
    
end

def annotations_two_installations_setup_backend(api, data_collection, ics_collection, project, display)

  create_project_and_display(api, project, display, data_collection, ics_collection)

  dc = Velocity::Collection.new(api, data_collection)
  dc.should_not be_nil
  begin
    dc.delete
  rescue
    #doesnt exist
  end
  dc.create
  original_seed = Nokogiri::XML "<call-function name=\"vse-crawler-seed-urls\" type=\"crawl-seed\"><with name=\"urls\">http://vivisimo.com</with><with name=\"hops\">1</with></call-function>"
  dc.add_seed(original_seed)

  acl_curl_option = Nokogiri::XML "<curl-option name=\"default-acl\">v.everyone</curl-option>"
  dc.add_curl_option(acl_curl_option)

  dc.start_crawl
  dc_search_result = dc.search("")

  dc_search_result.to_s.should_not match(/.*id=\'SEARCH_ENGINE_EMPTY_INDEX\'.*/)

  form_component = Nokogiri::XML("<call-function name=\"shared-folder-input\" />")
  s = Velocity::Source.new(api, data_collection)
  s.add_form_component(form_component)

  ics = Velocity::Collection.new(api, ics_collection)
  begin
    ics.delete
  rescue
    #doesnt exist
  end
  ics.create('ics-default')

  begin
    api.repository_delete({:element => 'source', :name => ics_collection})
  rescue
    #doesnt exist
  end
  icss_xml = Nokogiri::XML "<source name=\"#{ics_collection}\" type=\"ref\">
                              <add-sources names=\"ics-default-source\">
                                <with name=\"collection\">#{ics_collection}</with>
                                <with name=\"uses-acls\">false</with>
                              </add-sources>
                              <tests />
                              <help />
                              <description />
                            </source>"
  begin
    api.repository_add({:node => icss_xml.root})
  rescue
    #node already exists, overwrite
    api.repository_update({:node => icss_xml.root})
  end

end

def create_project_and_display(api, project, display, source, ics="", ics_url="", ics_user="", ics_pw="")
  project_xml = Nokogiri::XML "<options name=\"#{project}\" load-options=\"core\">
                                <load-options name=\"core\" />
                                <set-var name=\"render.function\">#{display}</set-var>
                                <set-var name=\"render.sources\">#{source}</set-var>
                                <set-var name=\"query.sources\">#{source}</set-var>
                                <set-var name=\"ics-collection\">#{ics}</set-var>
                                <set-var name=\"ics-url\">#{ics_url}</set-var>
                                <set-var name=\"ics-vivisimo-user\">#{ics_user}</set-var>
                                <set-var name=\"ics-vivisimo-password\">#{ics_pw}</set-var>
                               </options>"
  begin
    api.repository_add({:node => project_xml.root})
  rescue
    #node already exists, overwrite
    api.repository_update({:node => project_xml.root})
  end

  display_xml = Nokogiri::XML "<function name=\"#{display}\" type=\"display\">
                                <prototype />
                                <call-function name=\"velocity-display\" />
                                <settings>
                                  <setting name=\"keyword-name\"
                                           group-id=\"1252952030-Sq6H3ghDZzfQ\" 
                                           group=\"tags\"
                                           from=\"core-annotation\">tags</setting>
                                  <setting name=\"keyword-permission-scheme\"
                                           group-id=\"1252952030-Sq6H3ghDZzfQ\"
                                           group=\"tags\" 
                                           from=\"core-annotation\">no-acls</setting>
                                </settings>
                              </function>"
  begin
    api.repository_add({:node => display_xml.root})
  rescue
    #node already exists, overwrite
    api.repository_update({:node => display_xml.root})
  end

end