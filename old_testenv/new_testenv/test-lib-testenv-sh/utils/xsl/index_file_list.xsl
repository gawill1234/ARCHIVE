<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <xsl:variable name="status"
    select="/vse-collection/vse-status[@which='live']/vse-index-status"
  />
  <xsl:if test="count($status) != 1">
    <xsl:message terminate="yes">index_file_list:  Invalid number of live status nodes, there are <xsl:value-of select="count($status)"/> and I require exactly one.</xsl:message>
  </xsl:if>
  <xsl:for-each select="$status/vse-index-file[@type='index']">
     <xsl:variable name="docs-index" select="."/>
     <xsl:if test="$docs-index">
       <xsl:value-of select="$docs-index/@name"/>
       <xsl:text disable-output-escaping="yes"><![CDATA[ ]]></xsl:text>
     </xsl:if>
   </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
