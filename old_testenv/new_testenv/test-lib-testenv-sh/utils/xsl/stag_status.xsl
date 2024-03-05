<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:template match="/">
      <xsl:value-of select="//table/tr/td/div/font/table[3]/tr/td"/>
   </xsl:template>

</xsl:stylesheet>
