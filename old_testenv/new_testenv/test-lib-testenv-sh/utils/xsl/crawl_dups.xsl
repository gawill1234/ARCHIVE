<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:template match="/">
      <xsl:for-each select="/vse-collection/vse-status[@which='live']/crawler-status">
         <xsl:value-of select="@n-duplicates"/>
      </xsl:for-each>
   </xsl:template>

</xsl:stylesheet>
