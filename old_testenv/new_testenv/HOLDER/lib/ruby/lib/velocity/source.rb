module Velocity
  class Source
    def initialize(vapi, sources = 'example-metadata')
      @vapi = vapi
      @sources = sources
    end

    def create(xml=nil)
      if xml
        source_xml = Nokogiri::XML(xml)
      else
        source_xml = Nokogiri::XML("<source name=\"#{@sources}\" test-strictly=\"test-strictly\">
                                    <submit>
                                      <form />
                                    </submit>
                                    <tests />
                                    <help />
                                    <description />
                                  </source>")
      end

      begin
        @vapi.repository_add({:node => source_xml.root})
      rescue
        @vapi.repository_update({:node => source_xml.root})
      end
    end

    def search(query_object)
      @vapi.query_search({ :sources => @sources,
                           :query_object => query_object,
                           :num => 100 })
    end

    def get_config
      @vapi.repository_get({:element => "source", :name => @sources})
    end

    def add_form_component(form_component_xml)
      curr_xml = get_config
      curr_xml.xpath("//submit/form").first.add_child form_component_xml.root
      @vapi.repository_update(:node => curr_xml.root)
    end

    def add_vse_form_with(vse_form_with_xml)
      curr_xml = get_config
      curr_xml.xpath("//submit/form/call-function[@name='vse_form']").first.add_child vse_form_with_xml.root
      @vapi.repository_update(:node => curr_xml.root)
    end

    def delete
      @vapi.repository_delete({:element => "source", :name => @sources})
    end
  end
end
