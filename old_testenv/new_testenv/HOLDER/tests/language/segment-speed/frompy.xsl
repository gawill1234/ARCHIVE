<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:viv='http://vivisimo.com/exslt'
     xmlns:lxslt="http://xml.apache.org/xslt"
>

<xsl:output method="html"/>

<xsl:param name="data" as="xs:string"/>
<xsl:param name="segmenter" as="xs:string"/>
<xsl:param name="stemmer" as="xs:string"/>
<xsl:param name="kb" as="xs:string"/>

   <xsl:template name="dotheshit">
      <tr>
         <xsl:variable name="testval" select="normalize-space($data)"/>
         <xsl:variable name="seg" select="normalize-space($segmenter)"/>
         <xsl:variable name="stem" select="normalize-space($stemmer)"/>
         <xsl:variable name="kb" select="normalize-space($kb)"/>

         <td align="center"><i>
            <xsl:if test="string($testval) = ''">
               <xsl:text>Empty</xsl:text>
            </xsl:if>
            <xsl:if test="string($testval) != ''">
               <xsl:value-of select="string($testval)"/>
            </xsl:if>
         </i></td>
         <xsl:text>&#xa;</xsl:text>
         <td align="center"><i>
            <xsl:value-of select="$seg"/>
         </i></td>
         <xsl:text>&#xa;</xsl:text>
         <td align="center"><i>
            <xsl:value-of select="$stem"/>
         </i></td>
         <xsl:text>&#xa;</xsl:text>
         <td align="center"><i>
            <xsl:value-of select="$kb"/>
         </i></td>
         <xsl:text>&#xa;</xsl:text>
         <!--  This line is what we are actually testing -->
         <!--  string, stemmers, kbs, segmenters -->
         <xsl:variable name="resval" select="viv:stem-kb-key(string($testval), string($stem), string($kb), string($seg))"/>
         <td align="center"><i>
            <xsl:value-of select="$resval"/>
         </i></td>
         <xsl:text>&#xa;</xsl:text>
      </tr>
   </xsl:template>

   <xsl:template match="/">
      <xsl:call-template name="dotheshit"/>
   </xsl:template>
</xsl:stylesheet>

