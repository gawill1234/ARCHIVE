<?xml version="1.0" encoding="UTF-8"?>
<vce>
<scope>

<call-function name="axl-log">
  <with name="message">Start</with>
  <with name="name">benchmark1</with>
</call-function>

  <for-each select="file:list-directory('/usr/local/vivisimo-font-lang/data/japanese/seed-data/xml')" as="infile">
    <declare name="input" initial-select="file:read-xml(concat('/usr/local/vivisimo-font-lang/data/japanese/seed-data/xml/', $infile))" type="nodeset"/>

<!--
    <declare name="input" initial-select="file:read-xml(concat('/usr/local/vivisimo-font-lang/data/japanese/seed-data/xml/', '130107_6132005M1202_1_02.xml'))" type="nodeset"/>
-->

      <value-of select="viv:stem-kb-key($input,'depluralize','none','japanese')"/>

  </for-each>

<call-function name="axl-log">
  <with name="message">Finished processing all files in dir</with>
  <with name="name">benchmark2</with>
</call-function>
 </scope>

<!-- extracting the times -->
<scope>
  <process-xsl><![CDATA[
  <xsl:template match="/">
    <xsl:for-each select="str:tokenize(str:padding(2), '')">
      <bm>
        <xsl:value-of select="concat('benchmark', position(), ': ')" />
	<xsl:value-of select="viv:xml-index-retrieve('/usr/local/vivisimo-font-lang/tmp/axl-development.log', 'log', concat('benchmark', position()))/@time" />
      </bm>
    </xsl:for-each>
  </xsl:template>
  ]]></process-xsl>
</scope>


</vce>
