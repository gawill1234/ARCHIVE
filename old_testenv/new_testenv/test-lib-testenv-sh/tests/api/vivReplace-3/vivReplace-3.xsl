<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivReplace-3" modified-by="gary_testing" max-elt-id="1"
  modified="1209666370"
>
  <print><![CDATA[content-type:text/html

    
]]></print>
  <print>
    <parse encode="encode">
      <parser type="html-xsl"><![CDATA[

         <!-- <<<<<<<<<<<<<<<<<<<<< -->
         <xsl:output method="html" omit-xml-declaration="yes" indent="no" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
   <xsl:template match="/">
      <html>
      <title>
         vivReplace-3
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      vivReplace-3
      </font>
      <br/><br/>
      <b>Description:</b>  regex substring replacement, intervening space<br/><br/>
      <b>Function:</b>  viv:replace($string1,$string2,$string3,'gi')<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>string1:</b>   The quick brown fox jumps over the lazy dog
      </li>
      <li>
      <b>string2:</b>   q[uv][hi].*k
      </li>
      <li>
      <b>string3:</b>   slow
      </li>
      </ul>
      <b>Expected Result:</b>  The slow fox jumps over the lazy dog<br/><br/>
      <xsl:variable name="string1" select="string('The quick brown fox jumps over the lazy dog')"/>
      <xsl:variable name="string2" select="string('q[uv][hi].*n')"/>
      <xsl:variable name="string3" select="string('slow')"/>
      <xsl:variable name="expected" select="string('The slow fox jumps over the lazy dog')"/>
      <xsl:variable name="resval" select="viv:replace($string1,$string2,$string3,'gi')"/>
      <xsl:call-template name="PassFail">
         <xsl:with-param name="result" select="$resval"/>
         <xsl:with-param name="expect" select="$expected"/>
      </xsl:call-template>
      </body>
      </html>
   </xsl:template>

   <xsl:template name="PassFail">
      <xsl:param name="result"/>
      <xsl:param name="expect"/>
      <b>Actual Result:</b>
      <xsl:value-of select="$result"/>
      <br/>
      <xsl:choose>
         <xsl:when test="$result = $expect">
            <br/>
            <font color="green">
            <b>vivReplace-3:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>vivReplace-3:  TEST FAILED</b>
            </font>
            <br/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
    ]]></parser>
   </parse>
   <fetch timeout="10000" finish="finish" />
  </print>
</application>
</vce>
