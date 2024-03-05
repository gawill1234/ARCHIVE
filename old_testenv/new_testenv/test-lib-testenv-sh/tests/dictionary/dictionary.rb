require 'misc'

class Dictionary
  attr_reader :name

  def initialize(name, vapi = nil)
    @name = name.freeze

    if vapi
      @vapi = vapi
    else
      @vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
    end
  end

  def create(based_on = nil)
    @vapi.dictionary_create(:dictionary => @name, :based_on => based_on)
  end

  def delete
    @vapi.dictionary_delete(:dictionary => @name)
  end

  def stop_no_wait(args={})
    begin
      @vapi.dictionary_stop(args.merge(:dictionary => @name))
    rescue
      nil
    end
  end

  def dict_service_status
    status.xpath('//dictionary-status').first['status']
  end

  def stop(args={})
    while (dict_service_status != "finished" && dict_service_status != "aborted")
      stop_no_wait(args)
      sleep 1
    end
  end

  def kill
    stop_no_wait(:kill => true)
  end

  def build
    @vapi.dictionary_build(:dictionary => @name)
  end

  def status
    @vapi.dictionary_status_xml(:dictionary => @name)
  end

  def xml
    @vapi.repository_get(:element => 'dictionary', :name => @name)
  end

  def set_xml(xml)
    @vapi.repository_update(:node => xml)
  end

  def remove_all_inputs
    my_xml = xml
    my_xml.xpath('//dictionary-inputs/*').unlink
    set_xml(my_xml)
  end

  def add_file_input(path)
    create_and_add_input('dict-input-file', :path => path)
  end

  def add_collection_input(name, options={})
    options[:name] = name
    create_and_add_input('dict-input-collection', options)
  end

  def add_autocomplete_collection_input(name, options={})
    options[:name] = name
    create_and_add_input('dict-input-collection-autocomplete', options)
  end

  def set_stemmer(stemmer)
    set_dictionary_global_options(:input_stemmer => stemmer)
  end

  def set_tokenization(tokenize)
    set_dictionary_global_options(:should_tokenize => tokenize)
  end

  def set_min_length(min_length)
    set_dictionary_global_options(:min_length => min_length)
  end

  def set_prune(size)
    set_dictionary_global_options(:prune_size => size)
  end

  def set_rights_function(rights_function)
    my_xml = xml
    dict = my_xml.xpath('//dictionary').first
    dict['rights-function'] = rights_function
    set_xml(my_xml)
  end

  def set_to_autocomplete_output
    my_xml = xml
    my_xml.xpath('//dictionary-outputs/call-function').unlink
    xml_doc = my_xml.document
    cf = xml_doc.create_element('call-function')
    cf['name'] = 'dict-output-autocomplete-collection'

    my_xml.xpath('//dictionary-outputs').first << cf
    set_xml(my_xml)
  end

 def set_autocomplete_output_vis_node(vis)
    my_xml = xml
    cf = my_xml.xpath('//dictionary-outputs/call-function').first

    with = my_xml.create_element('with')
    with['name'] = 'vse-index-stream-node'
    with.content = vis
    cf << with

    set_xml(my_xml)
  end

 def set_to_autocomplete_vis_node_output
    my_xml = xml
    my_xml.xpath('//dictionary-outputs/call-function').unlink
    xml_doc = my_xml.document
    cf_str = <<EOF
<call-function name="dict-output-autocomplete-collection">
  <with name="vse-index-stream-node">
    &lt;vse-index-stream>
      &lt;vse-tokenizer name="literal" />
    &lt;/vse-index-stream>
  </with>
</call-function>
EOF

    cf_xml = Nokogiri::XML(cf_str)
    cf = cf_xml.document.xpath('//call-function').first

    my_xml.xpath('//dictionary-outputs').first << cf
    set_xml(my_xml)
  end

  def limit_to_wildcard_output
    my_xml = xml
    my_xml.xpath('//dictionary-outputs/call-function[@name != "dict-output-wildcard"]').unlink
    set_xml(my_xml)
  end

  def get_built_wildcard_dictionary
    gronk = Gronk.new
    install_path = gronk.installed_dir
    wc_path = "#{install_path}/data/dictionaries/#{@name}/wildcard.dict"
    gronk.get_file(wc_path, true)
  end

  def sort_and_save_built_wildcard_dictionary(path)
    File.open(path, 'w') do |f|
      lines = get_built_wildcard_dictionary.split("\n")
      lines.sort.each do |l|
        f.puts(l)
      end
    end
  end

  def upload_wildcard_dictionary_input(path)
    gronk = Gronk.new

    basename = File.basename(path)

    install_path = gronk.installed_dir
    dest_path = "#{install_path}/tmp/dictionary-wildcard-input-#{TESTENV.test_name}-#{basename}"
    gronk.send_file(path, dest_path)

    return dest_path
  end

  def errors
    status.xpath('//error')
  end

  def wait_until_finished(results, error_check = true)
    sleep_time = 0.1
    while true
      stat = status
      stat_xml = stat.xpath('//dictionary-status').first
      raise "no status attribute: #{stat}" unless stat_xml['status']

      if stat_xml['status'] == "finished"
        break
      end

      sleep sleep_time

      # Start out checking fast, get slower over time
      if (sleep_time < 5)
        sleep_time *=2
      else
        sleep_time = 5
      end
    end
    if (error_check)
      error = stat.xpath('//error')
      msg error if error.size.nonzero?
      results.add_number_equals(0, error.size, 'error')
    end
  end

  private

  def create_and_add_input(name, options = {})
    my_xml = xml

    cf = my_xml.create_element('call-function')
    cf['name'] = name.to_s

    options.each do |n, v|
      with = my_xml.create_element('with')
      with['name'] = n.to_s.gsub('_', '-')
      with.content = v.to_s
      cf << with
    end

    inputs = my_xml.xpath('//dictionary-inputs')[0]
    inputs << cf

    set_xml(my_xml)
  end

  def set_dictionary_global_options(options)
    my_xml = xml
    dict_xml = my_xml.xpath('//dictionary').first
    options.each do |k,v|
      k = k.to_s.gsub('_', '-')
      dict_xml[k] = v.to_s
    end
    set_xml(my_xml)
  end
end

class AutocompleteDictionary < Dictionary
  def create(based_on = 'base-autocomplete')
    @vapi.dictionary_create(:dictionary => @name, :based_on => based_on)
  end
end
