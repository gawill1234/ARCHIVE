<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:template match="/">
      <xsl:value-of select="//table[13]/tr[2]/td/table/tr/td"/>
   </xsl:template>

</xsl:stylesheet>
