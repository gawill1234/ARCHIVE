class Repository
  def initialize(vapi = nil)
    if vapi
      @vapi = vapi
    else
      @vapi = Vapi.new(velocity=TESTENV.velocity, user=TESTENV.user, password=TESTENV.password)
    end
  end

  def exists?(element_name, name)
    not @vapi.repository_list_xml.xpath("/vce/#{element_name}[@name='#{name}']").empty?
  end

  def delete(element_name, name)
    @vapi.repository_delete(:element => element_name, :name => name) if exists?(element_name, name)
  end

  def get(element_name, name)
    @vapi.repository_get(:element => element_name, :name => name).root
  end

  def add(node)
    @vapi.repository_add(:node => node)
  end

  def update(node)
    @vapi.repository_update(:node => node)
  end

  # When called with a block, the node is yielded to the block to
  # allow for modification before it is saved.
  def copy_node(element_name, source_name, destination_name)
    xml = get(element_name, source_name)
    xml = yield xml if block_given?
    xml['name'] = destination_name
    add(xml)
  end
end
