require "collection"

class AutocompleteBaseCollection < Collection
  def initialize(name)
    super(name)
  end

  def reset_and_configure_collection
    delete
    create('default-autocomplete')
  end
end

class AutocompleteDataCollection < AutocompleteBaseCollection
  def initialize
    super('data-collection-autocomplete')
  end

  def autocomplete_name
    return 'data-collection'
  end

  def setup
    reset_and_configure_collection

    data_xml_string = <<EOF
      <crawl-urls>
        <crawl-url url="a" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text" acl="1">foo data</content>
              <content name="ac.count" type="text" acl="1" indexed="false">5</content>
              <content name="author" count="1" type="text" acl="1" indexed="false">Joe</content>
              <content name="author" count="1" type="text" acl="1" indexed="false">Sally</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="b" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text" acl="2">data1 foo</content>
              <content name="ac.count" type="text" acl="2" indexed="false">4</content>
              <content name="author" count="1" type="text" acl="2" indexed="false">Sally</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="c" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text" acl="3">data1 bar</content>
              <content name="ac.count" type="text" acl="3" indexed="false">3</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="d" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text" acl="4">bar data1</content>
              <content name="ac.count" type="text" acl="4" indexed="false">2</content>
              <content name="image" count="1" type="text" acl="4" indexed="false">pic.jpg</content>
              <content name="url" count="1" type="text" acl="4" indexed="false">http://example.com</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="e" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text" acl="5">foo bar data2</content>
              <content name="ac.count" type="text" acl="5" indexed="false">1</content>
              <content name="author" count="1" type="text" acl="5" indexed="false">Joe</content>
            </document>
          </crawl-data>
        </crawl-url>
      </crawl-urls>
EOF
    data_xml = Nokogiri::XML(data_xml_string).root

    enqueue_xml(data_xml)
  end
end

class AutocompleteInputValidationCollection < AutocompleteBaseCollection
  def initialize
    super('input-validation-autocomplete')
  end

  def autocomplete_name
    return 'input-validation'
  end

  def setup
    reset_and_configure_collection

    data_xml_string = <<EOF
      <crawl-urls>
        <crawl-url url="a" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text">hello world</content>
              <content name="ac.count" type="text" indexed="false">5</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="b" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text">world hello</content>
              <content name="ac.count" type="text" indexed="false">4</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="c" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text">try using CONTENT text CONTAINING using</content>
              <content name="ac.count" type="text" indexed="false">3</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="d" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text">say hello OR get out of the world!</content>
              <content name="ac.count" type="text" indexed="false">2</content>
            </document>
          </crawl-data>
        </crawl-url>
        <crawl-url url="e" status="complete" synchronization="indexed">
          <crawl-data encoding="xml" content-type="application/vxml">
            <document>
              <content name="ac.phrase" type="text">she said "!@#% yourself"</content>
              <content name="ac.count" type="text" indexed="false">1</content>
            </document>
          </crawl-data>
        </crawl-url>
      </crawl-urls>
EOF
    data_xml = Nokogiri::XML(data_xml_string).root

    enqueue_xml(data_xml)
  end
end
