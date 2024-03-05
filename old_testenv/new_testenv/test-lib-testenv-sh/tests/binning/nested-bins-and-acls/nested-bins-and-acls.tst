#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'oracle-ship-collection'

BINNING_XML = <<XML
<binning-sets>
  <binning-set>
    <call-function name="binning-set">
      <with name="bs-id">ship</with>
      <with name="select">$SHIP_TYPE</with>
      <with name="label">ship</with>
    </call-function>

    <binning-set>
      <call-function name="binning-set">
        <with name="bs-id">nations</with>
        <with name="select">$NATION</with>
        <with name="label">nations</with>
      </call-function>
    </binning-set>
  </binning-set>

  <binning-set>
    <call-function name="binning-set">
      <with name="bs-id">align</with>
      <with name="select">$ALIGNED</with>
      <with name="label">align</with>
    </call-function>
</binning-sets>
XML

CONVERTER_XML = <<XML
<converter type-in="application/vxml-db" type-out="application/vxml-db">
<parser type="xsl" >
&lt;xsl:template match="/">
  &lt;xsl:apply-templates select="//document" />
&lt;/xsl:template>

&lt;xsl:template match="document">
  &lt;document>
    &lt;xsl:apply-templates select="content" />
  &lt;/document>
&lt;/xsl:template>

    &lt;xsl:template match="content[@name='NATION']">
      &lt;content>
        &lt;xsl:attribute name="name">
          &lt;xsl:value-of select="@name" />
        &lt;/xsl:attribute>
        &lt;xsl:attribute name="acl">
          &lt;xsl:choose>
            &lt;xsl:when test=". = 'Japan'">&lt;![CDATA[-gillin
everyone]]>&lt;/xsl:when>
            &lt;xsl:otherwise>&lt;![CDATA[gillin
everyone]]>&lt;/xsl:otherwise>
          &lt;/xsl:choose>
        &lt;/xsl:attribute>
        &lt;xsl:value-of select="." />
      &lt;/content>
    &lt;/xsl:template>

    &lt;xsl:template match="content[@name!='NATION']">
      &lt;content>
        &lt;xsl:attribute name="name">
          &lt;xsl:value-of select="@name" />
        &lt;/xsl:attribute>
          &lt;xsl:if test="../content[@name='NATION']/text() != 'Japan'">
            &lt;xsl:attribute name="acl">&lt;![CDATA[gillin
everyone]]>&lt;/xsl:attribute>
          &lt;/xsl:if>
        &lt;xsl:value-of select="." />
      &lt;/content>
    &lt;/xsl:template>
  </parser>
</converter>
XML

VSE_FORM_XML = <<XML
<with name="rights">&lt;value-of-var name="rights" realm="param" /></with>
XML

results = TestResults.new("Setting and specifying acl's alongside nested ",
                          "binning-states does not fail to return documents.")

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)

collection = OracleShipCollection.new(vapi, Collection.new(TESTENV.test_name))
collection.prepare_binning_collection(BINNING_XML)
results.associate(collection)

collection.add_vse_form_with(VSE_FORM_XML)
collection.add_converter(CONVERTER_XML)

collection.crawl

results.add_number_equals(359, collection.index_n_docs, "indexed document")

msg("Everyone should be able to see 3 results for 'binning-state=ship==Destroyer\\nnations==Japan")
collection.search_by_refinement("ship==Destroyer\nnations==Japan",
                                {:authorization_rights => 'everyone'})
results.add_number_equals(3, collection.document_count, "Japanese destroyer")
results.add_set_equals(%w{Ayanami Minegumo Murasame}, collection.document_names,
                       "Japanese destroyer")

msg("Gillin should not be able to see results for 'binning-state=ship==Destroyer\\nnations==Japan")
collection.search_by_refinement("ship==Destroyer\nnations==Japan",
                                {:authorization_rights => 'gillin'})
results.add_number_equals(0, collection.document_count, "Japanese destroyer")
results.add_set_equals(%w{}, collection.document_names, "Japanese destroyer name")


msg("Gillin should be able to see 74/77 results for 'binning-state=ship==Destroyer")
collection.search_by_refinement("ship==Destroyer",
                                {:authorization_rights => 'gillin'})
results.add_number_equals(74, collection.document_count, "destroyer")
results.add_set_equals(%w{Acasta Achates Acheron Active Afridi Alden Alden
                          Amazon Ambuscade Antelope},
                      collection.document_names, "destroyer name")

results.cleanup_and_exit!
