<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--   ###########################################################  -->
<!--   Everything in this file processes the xml returned by a      -->
<!--   query.                                                       -->
<!--   ###########################################################  -->

<!--   ###########################################################  -->
<!--   Make the output be raw text.  This way we don't get that     -->
<!--   Irritating <?xml version="1.0"?> line as the first line      -->
<!--   of output.                                                   -->
<xsl:output method="text"/>

<!--  which command to execute  -->
<xsl:param name="mynode" as="xs:string"/>

<!--  parameter type (if needed)  -->
<xsl:param name="which" as="xs:string"/>

<!--  value paramter of command or type parameter  -->
<xsl:param name="value" as="xs:string"/>

   <!-- here is the template that does the replacement -->
   <xsl:template name="replaceCharsInString">
     <xsl:param name="stringIn"/>
     <xsl:param name="charsIn"/>
     <xsl:param name="charsOut"/>
     <xsl:choose>
       <xsl:when test="contains($stringIn,$charsIn)">
         <xsl:value-of select="concat(substring-before($stringIn,$charsIn),$charsOut)"/>
         <xsl:call-template name="replaceCharsInString">
           <xsl:with-param name="stringIn" select="substring-after($stringIn,$charsIn)"/>
           <xsl:with-param name="charsIn" select="$charsIn"/>
           <xsl:with-param name="charsOut" select="$charsOut"/>
         </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="$stringIn"/>
       </xsl:otherwise> </xsl:choose>
   </xsl:template>

   <xsl:template name="get_url_errors">
      <xsl:for-each select="//td">
         <xsl:if test="./a/@target = '_blank'">
            <xsl:value-of select="."/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>

   <xsl:template match="/">
      <xsl:choose>
         <!--   Get the url count from "total-results" -->
         <xsl:when test="$mynode = 'url_error'">
            <xsl:call-template name="get_url_errors"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
