#!/usr/bin/env ruby
#
# Test: Bug 29406
#
# Test that we don't drop actually significant digits when displaying doubles as
# sort-keys.

$LOAD_PATH << ENV['TEST_ROOT'] + '/lib'

require 'collection'
require 'misc'
require 'nokogiri'
require 'velocity/source'

#Constants
velocity      = TESTENV.velocity
user          = TESTENV.user
password      = TESTENV.password
testname      = TESTENV.test_name
COLLECTION_A  = testname + "-a"
COLLECTION_B  = testname + "-b"
XPATH_CCONFIG = "/vse-collection/vse-config/crawler"
XPATH_ICONFIG = "/vse-collection/vse-config/vse-index"
XPATH_DOCS    = "//document"
XPATH_TITLE   = "content[@name='title']"
XPATH_SORTKEY = "sort-key"
CRAWL_OPTIONS = <<END
<crawl-options>
  <crawl-option name="default-allow">allow</crawl-option>
</crawl-options>
END
INDEX_OPTIONS = <<END
<vse-index-option name="fast-index">secondly|double</vse-index-option>
END
CRAWL_URLS_A  = <<END
<crawl-urls>
  <crawl-url url="fake://origina.ls/1" synchronization="indexed"
      status="complete" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>
        <content name="title">Return of the Jedi</content>
        <content name="secondly">1.360001774E12</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://origina.ls/9" synchronization="indexed"
      status="complete" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>
        <content name="title">Empire Strikes Back</content>
        <content name="secondly">1.360001775E12</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://preque.ls/6"  synchronization="indexed"
      status="complete" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>
        <content name="title">Attack of the Clones</content>
        <content name="secondly">1.360001778E12</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://origina.ls/3"  synchronization="indexed"
      status="complete" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>
        <content name="title">A New Hope</content>
        <content name="secondly">1.360001776E12</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
END
CRAWL_URLS_B  = <<END
<crawl-urls>
  <crawl-url url="fake://preque.ls/4"  synchronization="indexed"
      status="complete" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>
        <content name="title">The Phantom Menace</content>
        <content name="secondly">1.360001779E12</content>
      </document>
    </crawl-data>
  </crawl-url>
  <crawl-url url="fake://preque.ls/2"  synchronization="indexed"
      status="complete" enqueue-type="reenqueued">
    <crawl-data content-type="application/vxml-unnormalized" encoding="xml">
      <document>
        <content name="title">Revenge of the Sith</content>
        <content name="secondly">1.360001777E12</content>
      </document>
    </crawl-data>
  </crawl-url>
</crawl-urls>
END
BUNDLE_XML    = <<END
<source name="#{testname}" test-strictly="test-strictly" type="bundle">
<add-sources names="#{COLLECTION_A}"/>
<add-sources names="#{COLLECTION_B}"/>
</source>
END
CORRECT_ORDER = [ "The Phantom Menace", "Attack of the Clones",
                  "Revenge of the Sith", "A New Hope", "Empire Strikes Back",
                  "Return of the Jedi" ]

#Helper Functions
def gen_source_xml(name)
  <<END
<source internal="7.x" name="#{name}" type="vse"
    test-strictly="test-strictly" products="core">
  <prototype>
    <declare name="staging" initial-value="false" type="boolean">
      <description>
        Flag used to allow querying of the staging index.
      </description>
    </declare>
  </prototype>
  <submit>
    <form>
      <call-function name="vse_form">
        <with name="fi-sort">date|descending:$last-modified
secondly|descending:$secondly</with>
        <with name="collection">#{name}</with>
        <with name="staging" copy-of="staging" />
      </call-function>
      <call-function name="vse-input-date" />
    </form>
  </submit>
</source>
END
end

#Test
##0. Initialization Test Framework
vapi = Vapi.new(velocity, user, password)
test_results = TestResults.new(testname,
                 "Test that we don't drop actually significant ",
                 "digits when displaying doubles as sort-keys. ",
                 "Data is structured so that the test also checks ",
                 "aggregated sorting in a bundle.")

##1. Configure Collections and Sources
collection_a = Collection.new(COLLECTION_A, velocity, user, password)
test_results.associate(collection_a)
collection_a.delete
collection_a.create("default")
xml = collection_a.xml
xml.xpath(XPATH_CCONFIG).children.before(CRAWL_OPTIONS)
xml.xpath(XPATH_ICONFIG).children.before(INDEX_OPTIONS)
collection_a.set_xml(xml)

collection_b = Collection.new(COLLECTION_B, velocity, user, password)
test_results.associate(collection_b)
collection_b.delete
collection_b.create(COLLECTION_A)

Velocity::Source.new(vapi, COLLECTION_A).create(gen_source_xml(COLLECTION_A))
Velocity::Source.new(vapi, COLLECTION_B).create(gen_source_xml(COLLECTION_B))
Velocity::Source.new(vapi, testname).create(BUNDLE_XML)

##1. Enqueue Data
collection_a.enqueue_xml(CRAWL_URLS_A)
collection_b.enqueue_xml(CRAWL_URLS_B)

##2. Query the Bundled Source
query_result = vapi.query_search({ :sources => testname, :query => nil,
                                   :sort_by => "secondly", :aggregate => true,
                                   :output_sort_keys => true})

##3. Ensure that the returned documents are in the correct order.
query_result.xpath(XPATH_DOCS).each_with_index do |doc, i|
  title = doc.xpath(XPATH_TITLE).text
  sort_key = doc.xpath(XPATH_SORTKEY).attr("value")

  test_results.add(title.eql?(CORRECT_ORDER[i]),
                   "The ##{i} document is #{title} as was expected.",
                   "Expected #{CORRECT_ORDER[i]} as the ##{i} document, but en"\
                   "countered #{title} (with sort-key value #{sort_key}) inste"\
                   "ad.")
end


#Cleanup
test_results.cleanup_and_exit!
