require 'misc'
require 'collection'
require 'delegate'
require 'velocity/source'
require 'velocity/repository'

class ShipCollection < SimpleDelegator
  def initialize(vapi, collection)
    super(collection)
    @vapi = vapi
  end

  def prepare_binning_collection(binning_xml)
    set_crawl_options({:default_acl => "everyone"}, {})
    set_index_options({:output_contents       => "NAME SHIP_TYPE NATION ALIGNED",
                       :fast_index            => "NAME\nSHIP_TYPE\nNATION\nALIGNED",
                       :duplicate_elimination => "false"})

    config_xml = xml
    config_xml.xpath("/vse-collection/vse-config/vse-index").children.before(binning_xml)
    set_xml(config_xml)

    @source = Velocity::Source.new(@vapi, name)
    @source.add_vse_form_with("<with name='fi-sort'>name|ascending:$NAME</with>")
  end

  def add_vse_form_with(with_xml)
    @source.add_vse_form_with(with_xml)
  end

  def add_converter(converter_xml)
    config_xml = xml
    config_xml.xpath("/vse-collection/vse-config/converters").children.before(converter_xml)
    set_xml(config_xml)
  end

  def add_syntax(syntax_name, syntax_xml)
    @syntax_name = syntax_name

    repository = Repository.new(vapi)

    if repository.exists?("syntax", @syntax_name)
      repository.delete("syntax", @syntax_name)
    end
    repository.add(syntax_xml)
  end


  def crawl
    crawler_start
    wait_until_idle
  end

  def search(query, options = {})
    opts = {:query   => query,
            :sources =>name}
    @result_xml = @vapi.query_search(opts.merge(options))
  end

  def search_by_metadata_field(query)
    @result_xml = search(query, {:syntax_repository_node => @syntax_name})
  end

  def search_by_refinement(binning_state, extra_opts={})
    opts = {:binning_state => binning_state,
            :sort_by       => "name"}
    @result_xml = search("", opts.merge(extra_opts))
  end

  def document_count
    @result_xml.xpath("//added-source").first["total-results-with-duplicates"].to_i
  end

  def document_names
    @result_xml.xpath("//document/content[@name='NAME']").map {|name| name.content}
  end

  def results_empty?
    document_count.eql?(0) && document_names.eql?([])
  end
end
