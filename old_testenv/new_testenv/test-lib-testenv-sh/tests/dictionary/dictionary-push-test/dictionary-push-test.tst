#!/usr/bin/env ruby
$LOAD_PATH << ENV['TEST_ROOT']+'/tests/dictionary'
require "misc"
require "collection"
require 'autocomplete'
require 'dictionary_collections'
require 'dictionary'
require 'velocity/example_metadata'

results = TestResults.new('Basic test to see if dictionary autocomplete collection push works')
results.need_system_report = false

input_collection = DictionarySimple.new
results.associate(input_collection)
input_collection.setup

dict = AutocompleteDictionary.new(TESTENV.test_name)
results.associate(dict)
dict.delete
dict.create

output_collection = Collection.new(TESTENV.test_name + '-autocomplete')
results.associate(output_collection)
output_collection.delete

example_metadata = ExampleMetadata.new
example_metadata.ensure_correctness

autocomplete = Autocomplete.new(TESTENV.test_name)

class AutocompleteDictionary
  def setup_and_build(results)
    remove_all_inputs

    yield self

    set_tokenization(true)
    build
    wait_until_finished(results)
  end
end

#Test pushing to ac collection
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(example_metadata.name, :contents => 'hero')
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')
correct_suggestions = ['gilbert', 'gold', 'goodwell', 'gwen']
autocomplete.ensure_correct_suggestions('g', nil, results, correct_suggestions)

#Test pushing to ac collection with existing data
dict.setup_and_build(results) do |dict|
  dict.add_collection_input(input_collection.name)
  dict.set_tokenization(true)
end

correct_suggestions = ['hotel']
autocomplete.ensure_correct_suggestions('h', nil, results, correct_suggestions)

#Test pushing to ac collection with empty content nodes
collection_with_empty_nodes = Collection.new(TESTENV.test_name + '-empty-nodes')
results.associate(collection_with_empty_nodes)
collection_with_empty_nodes.delete
collection_with_empty_nodes.create('example-metadata')

CONVERTER_XPATH = "//vse-config/converters/converter[@timing-name = 'Create Metadata from Content']"

CONVERTER_XML = <<XML
  <converter timing-name="Create Metadata from Content" type-in="text/html" type-out="application/vxml-unnormalized">
    <parser type="html-xsl"><![CDATA[<xsl:template match="/">
  <document>
    <content name="title" output-action="bold" weight="3">
      <xsl:value-of select="html/body/h1" />
    </content>
    <xsl:apply-templates select="//td/@id" />
  </document>
</xsl:template>

<xsl:template match="td/@id">
  <xsl:choose>
    <xsl:when test=" . = 'synopsis'">
      <content name="snippet">
        <xsl:value-of select=".." />
      </content>
    </xsl:when>
    <xsl:otherwise>
      <content name="{.}">
        <xsl:value-of select="''" />
      </content>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
]]></parser>
  </converter>
XML

collection_with_empty_nodes.remove_config_at(CONVERTER_XPATH)
collection_with_empty_nodes.add_converter_in_front(CONVERTER_XML)

collection_with_empty_nodes.crawler_start
collection_with_empty_nodes.wait_until_idle

dict.setup_and_build(results) do |dict|
  dict.add_collection_input(collection_with_empty_nodes.name)
  dict.set_tokenization(true)
end

results.add(output_collection.exists?, 'Collection exists', 'Could not create collection')
correct_suggestions = ['being', 'betty', 'becoming', 'been', 'before',
  'begins', 'beautiful', 'become', 'becomes', 'beast', 'because',
  'bending', 'between']
autocomplete.ensure_correct_suggestions('be', {:num => 200}, results, correct_suggestions)
results.cleanup_and_exit!(true)
