<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

   <xsl:template match="/">
      <xsl:for-each select="//vse-collection">
         <xsl:variable name="colnm" select="@name"/>
         <xsl:choose>
            <xsl:when test="$colnm = $collection">
               <xsl:copy-of select="."/>
            </xsl:when>
         </xsl:choose>
      </xsl:for-each>
   </xsl:template>

</xsl:stylesheet>
