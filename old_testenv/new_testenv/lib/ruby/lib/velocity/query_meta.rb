require 'simple_http'

module Velocity
  class QueryMeta
    attr_reader :vxml

    def initialize(query_meta_url, username = nil, password = nil)
      @query_meta_url = query_meta_url
      @http = SimpleHTTP.new(query_meta_url, {'Accept' => 'text/xml,application/xml'})
    end

    def query(params = {})
      @response = @http.post(params)
      if params['render.function'] == 'vxml-display'
        @vxml = Nokogiri::XML(@response.body)
        return @vxml
      else
        return @response.body
      end
    end
    
    def query_vxml(params = {})
      vxml_params = {'render.function' => 'vxml-display'}
      query(vxml_params.merge(params))
    end
    
    def temp_QEdisplay_query_1
      # TODO: should raise exception if trying to get last query of HTML version
      @vxml.xpath('/*/query[position() = last()-2]')
    end

   # when QE stemming is enabled, this is the one that contains the @use information 
    def temp_QEdisplay_query_2
      # TODO: should raise exception if trying to get last query of HTML version
      @vxml.xpath('/*/query[position() = last()-1]')
    end

    def last_query
      # TODO: should raise exception if trying to get last query of HTML version
      @vxml.xpath('/*/query[position() = last()]')
    end
  end
end
