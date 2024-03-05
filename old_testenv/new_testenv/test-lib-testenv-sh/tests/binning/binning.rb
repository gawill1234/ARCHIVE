module Binning

  class Result
    def initialize(xml)
      @xml = xml
    end

    def within(bs_id)
      yield Binning::Nav.new(@xml.xpath("//binning-set[@bs-id='#{bs_id}']"))
    end

    def content_values(content_name)
      contents = @xml.xpath("//document/content[@name='#{content_name}']")
      contents.map {|content| content.content }
    end

    def document_count
        @xml.xpath('//document').count
    end

    def ids_for_errors
      errors = @xml.xpath("//error")
      error_ids = errors.map {|e| e['id'] }
    end
  end

  class Nav
    def initialize(xml)
      @xml = xml
    end

    def labels
      bins = @xml.xpath("./bin")
      bins.map {|b| b['label'] }.sort
    end

    def active_labels
      bins = @xml.xpath("./bin[@active='active']")
      bins.map {|b| b['label'] }.sort
    end

    def within(label)
      yield Nav.new(@xml.xpath("./bin[@label='#{label}']"))
    end
  end

  class Search
    attr_reader :vapi

    def initialize(vapi, sources, binning_xml)
      @search_config = {'sources' => sources,
        'binning-configuration' => binning_xml,
        'binning-mode' => 'normal'}
      @vapi = vapi
      @binning_state = []
    end

    def activate_facet(bs_id, facet_name, custom_settings={})
      binning_state = @binning_state.dup
      binning_state << get_facet_state(bs_id, facet_name)

      fetch_results(custom_settings, binning_state)

      nil
    end

    def activate_facet_and_save(bs_id, facet_name, custom_settings={})
      @binning_state << get_facet_state(bs_id, facet_name)

      fetch_results(custom_settings, @binning_state)
    end

    private

    def result
      @xml ||= @vapi.query_search(@search_config)
    end

    def get_facet_state(bs_id, facet_name)
      binning_set_xpath = "//binning/binning-set[@bs-id='#{bs_id}']"
      facet_xpath = ".//bin[@label='#{facet_name}']"

      binning_set = result.xpath(binning_set_xpath).first

      facet_xml = binning_set.xpath(facet_xpath).first
      raise "No facet with name #{facet_name}" unless facet_xml

      facet_xml['state']
    end

    def fetch_results(custom_settings, binning_state)
      settings = @search_config.dup
      settings['binning-state'] = binning_state.join("\n")

      @xml = @vapi.query_search(settings.merge(custom_settings))

      Binning::Result.new(@xml)
    end
  end
end
