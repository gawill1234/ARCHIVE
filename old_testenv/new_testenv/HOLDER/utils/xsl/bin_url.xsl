<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:template match="/">
      <xsl:for-each select="//document">
         <xsl:sort select="@url"/>
         <xsl:value-of select="@url"/>
         <xsl:text><![CDATA[
]]></xsl:text>
      </xsl:for-each>
   </xsl:template>

</xsl:stylesheet>
