require 'vapi'

class Vapi
  def create_public_api_wrapper(name, parameters, options={})
    if options[:name]
      fn_name = options[:name]
    else
      fn_name = name.gsub(':', '-')
    end

    # Remove existing copy
    begin
      repository_get_md5(:element => 'function',
                              :name => fn_name)
      repository_delete(:element => 'function',
                             :name => fn_name)
    rescue
    end

    xml_doc = Nokogiri::XML::Document.new

    fn = xml_doc.create_element('function')
    fn['name'] = fn_name
    fn['type'] = 'public-api'

    proto = xml_doc.create_element('prototype')
    fn << proto

    parameters.each do |param|
      # Skip values we are going to hard-code
      next if param[:value]

      decl = xml_doc.create_element('declare')
      decl['name'] = param[:name]
      decl['required'] = 'required' if param[:required]
      decl['type'] = param[:type] if param[:type]

      proto << decl
    end

    desc = xml_doc.create_element('description')
    desc.content = "Automatically generated wrapper function for #{name}"
    proto << desc

    select_params = parameters.map do |param|
      if param[:value]
        param[:value]
      else
        "$#{param[:name]}"
      end
    end
    select = "#{name}(#{select_params.join(', ')})"

    if options[:returns => :nodeset]
      eval = xml_doc.create_element('copy-of')
    else
      eval = xml_doc.create_element('value-of')
    end
    eval['select'] = select
    fn << eval

    repository_add(:node => fn)
  end
end
