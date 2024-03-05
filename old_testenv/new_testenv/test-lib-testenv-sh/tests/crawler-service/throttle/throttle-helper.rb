require 'collection'
require 'vapi'

def remove_normalization_converter
  @collection.remove_config_at("//converter[@type-in='application/vxml-unnormalized']")
end

def add_delay_converter
  converter = <<-HERE
  <converter timing-name="delay" type-in="application/vxml-unnormalized" type-out="application/vxml-unnormalized">
    <parser type="xsl">
      <![CDATA[<xsl:template match="/">
        <xsl:variable name="delay" select="viv:sleep(30)" />
        <xsl:apply-templates select="." mode="copy" />
      </xsl:template>

      <xsl:template match="@* | text() | comment()" mode="copy">
        <xsl:copy />
      </xsl:template>

      <xsl:template match="*" mode="copy">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="copy" />
          <xsl:apply-templates mode="copy" />
        </xsl:copy>
      </xsl:template>]]>
    </parser>
  </converter>
  HERE
  @collection.add_converter(converter)
end

def setup
  @test_results.associate(@collection)
  @collection.delete
  @collection.create
  velocity = TESTENV.velocity
  user = TESTENV.user
  password = TESTENV.password
  @vapi = Vapi.new(velocity, user, password)
  remove_normalization_converter
  add_delay_converter
  @collection.set_crawl_options({ :n_link_extractor => "10",
                                  :enqueue_high_water => "3",
                                  :enqueue_low_water => "1" },
                                [])
  @collection.set_index_options({ :build_flush => "1",
                                  :build_flush_idle => "1" }
                                )
end

def enqueue_response_matches_pipeline_size(node, expected_size)
  response = @vapi.search_collection_enqueue_xml(
                                  :collection => TESTENV.test_name,
                                  :subcollection => "live",
                                  :crawl_nodes => node)
  size = response.xpath("/crawler-service-enqueue-response").attribute("pipeline-size").value.to_i
  expected_size == size ? true : false
end

# Helper function
def get_enqueue_response_throttle_id(node)
  response = @vapi.search_collection_enqueue_xml(
                                  :collection => TESTENV.test_name,
                                  :subcollection => "live",
                                  :crawl_nodes => node)
  throttle_id = response.xpath("/crawler-service-enqueue-response").attribute("throttle-id")
end

def enqueue_response_has_throttle_id(node)
  throttle_id = get_enqueue_response_throttle_id(node)
  throttle_id
end

def enqueue_response_matches_throttle_id(node, throttle_id)

  new_throttle_id = get_enqueue_response_throttle_id(node)

  new_throttle_id && (new_throttle_id.value.eql?(throttle_id))
end

def enqueue_response_has_throttle_id_greater_or_equal(node, throttle_id)

  new_throttle_id = get_enqueue_response_throttle_id(node)

  new_throttle_id && (new_throttle_id.value >= throttle_id)
end

# test data
CRAWL_URL_1 = <<-HERE
<crawl-url enqueue-type="reenqueued"
           status="complete"
           synchronization="enqueued"
           url="dummy-a"
           >
  <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
    <document>Hello world</document>
  </crawl-data>
</crawl-url>
HERE

CRAWL_URL_2 = <<-HERE
<crawl-url enqueue-type="reenqueued"
           status="complete"
           synchronization="enqueued"
           url="dummy-b"
           >
  <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
    <document>Hello world</document>
  </crawl-data>
</crawl-url>
HERE

CRAWL_URLS = <<-HERE
<crawl-urls>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="enqueued"
             url="dummy-c"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="enqueued"
             url="dummy-d"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
HERE

INDEX_ATOMIC = <<-HERE
<index-atomic>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="enqueued"
             url="dummy-e"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
  <crawl-url enqueue-type="reenqueued"
             status="complete"
             synchronization="enqueued"
             url="dummy-f"
             >
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>Hello world</document>
    </crawl-data>
  </crawl-url>
</index-atomic>
HERE

CRAWL_DELETE = <<-HERE
<crawl-delete url="dummy-a" enqueue-type="reenqueued" synchronization="enqueued" />
HERE
