<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="mytrib" as="xs:string"/>

   <xsl:template match="/">
      <xsl:for-each select="//bin">
         <xsl:sort select="(@*[local-name()=$mytrib])[position()=1]"/>
         <xsl:value-of select="(@*[local-name()=$mytrib])[position()=1]"/>
         <xsl:text><![CDATA[
]]></xsl:text>
      </xsl:for-each>
   </xsl:template>

</xsl:stylesheet>
