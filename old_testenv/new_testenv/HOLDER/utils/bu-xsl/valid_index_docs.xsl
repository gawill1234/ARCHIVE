<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <xsl:variable name="status"
    select="/vse-collection/vse-status[@which='live']/vse-index-status"
  />
  <xsl:if test="count($status) != 1">
    <xsl:message terminate="yes">Invalid number of live status nodes, there are <xsl:value-of select="count($status)"/> and I require exactly one.</xsl:message>
  </xsl:if>
  <xsl:variable name="docs-data"
    select="$status/vse-index-file[@type='docs-data']"
  />
  <xsl:choose>
    <xsl:when test="$docs-data">
      <xsl:value-of select="$docs-data/@n-docs"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$status/vse-index-file[@type='index']/@n-docs"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
