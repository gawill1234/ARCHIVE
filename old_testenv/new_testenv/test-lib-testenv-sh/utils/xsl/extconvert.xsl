<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    version   = "1.0"
    xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
    xmlns:math= "http://exslt.org/math"
    xmlns:str = "http://exslt.org/strings"
    xmlns:dyn = "http://exslt.org/dynamic"
    xmlns:exsl= "http://exslt.org/common"
    xmlns:set = "http://exslt.org/sets"
    xmlns:date= "http://exslt.org/dates-and-times"
    xmlns:func= "http://exslt.org/functions"
    xmlns:lib = "http://xmlsoft.org/XSLT/namespace"
    xmlns:viv = "http://vivisimo.com/exslt"
    extension-element-prefixes="math str dyn exsl set date func lib viv" >

  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="mynode" as="xs:string"/>

  <xsl:template match="/">
     <xsl:choose>
        <xsl:when test="$mynode = 'internal_default'">
           <xsl:apply-templates select="//vse-collection[@name='default']//converters"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:apply-templates select="//converters"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!-- Copy comments and text nodes -->
  <xsl:template match="comment()|text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="converters">
     <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

