<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>

<xsl:param name="mynode" as="xs:string"/>
<xsl:param name="mytrib" as="xs:string"/>


   <xsl:template name="countpid">
      <xsl:value-of select="count(/REMOP/PIDLIST/PID)"/>
   </xsl:template>

   <xsl:template name="pidlist">
      <xsl:for-each select="/REMOP/PIDLIST/PID">
         <xsl:value-of select="."/>
         <xsl:text>&#xa;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <xsl:template match="/">
      <xsl:choose>
         <xsl:when test="$mynode = 'pid-count'">
            <xsl:call-template name="countpid"/>
         </xsl:when>
         <xsl:when test="$mynode = 'pid-list'">
            <xsl:call-template name="pidlist"/>
         </xsl:when>
         <xsl:otherwise>
           <xsl:text><![CDATA[0]]></xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>


</xsl:stylesheet>
