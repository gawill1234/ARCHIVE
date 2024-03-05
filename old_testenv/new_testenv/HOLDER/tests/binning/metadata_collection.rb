require "collection"

class MetadataCollection
  def initialize(name)
    @collection = Collection.new(name)
    @current_id = 0
  end

  def name
    @collection.name
  end

  def add_document(contents_and_values)
    crawl_url = template_xml
    crawl_url['url'] = "test://127.0.0.1/#{@current_id}"
    @current_id += 1

    document = crawl_url.xpath('//document').first

    contents_and_values.each do |content_name, content_values|
      Array(content_values).each do |content_value|
        content = xml_document.create_element('content')
        content['name'] = content_name.to_s
        content['fast-index'] = 'set'
        content.content = content_value

        document << content
      end
    end

    crawl_urls << crawl_url
  end

  def save!
    @collection.delete
    @collection.create('default-push')
    @collection.enqueue_xml(crawl_urls)
  end

  private

XML_TEMPLATE = <<EOF
<crawl-url url="REPLACE" status="complete" synchronization="indexed">
  <crawl-data encoding="xml" content-type="application/vxml">
    <document />
  </crawl-data>
</crawl-url>
EOF

  def template_xml
    Nokogiri::XML(XML_TEMPLATE).root
  end

  def xml_document
    template_xml.document
  end

  def crawl_urls
    @crawl_urls ||= xml_document.create_element('crawl-urls')
  end
end
