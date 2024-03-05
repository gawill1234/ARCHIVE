<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivStrToLower-7" modified-by="gary_testing" max-elt-id="1"
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
         vivStrToLower-7
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      vivStrToLower-7
      </font>
      <br/><br/>
      <b>Description:</b>  vivStrToLower-7 -- mixed case, mixed char alpha string variable alpha to lower case<br/><br/>
      <b>Function:</b>  viv:str-to-lower($string1)<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>string1:</b>   aAaA;bBbB
      </li>
      </ul>
      <b>Expected Result:</b>  aaaa;bbbb<br/><br/>
      <xsl:variable name="string1" select="string('aAaA;bBbB')"/>
      <xsl:variable name="expected" select="string('aaaa;bbbb')"/>
      <xsl:variable name="resval" select="viv:str-to-lower($string1)"/>
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
            <b>vivStrToLower-7:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>vivStrToLower-7:  TEST FAILED</b>
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
