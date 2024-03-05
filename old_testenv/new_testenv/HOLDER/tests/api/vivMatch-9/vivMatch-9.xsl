<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivMatch-9" modified-by="gary_testing" max-elt-id="1"
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
         vivMatch-9
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      vivMatch-9
      </font>
      <br/><br/>
      <b>Description:</b>  match of string in parens, ignore case<br/><br/>
      <b>Function:</b>  viv:match($matchString,$regexStr, 'i')<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>matchString:</b>   ignore (parenthesis match test) ignore
      </li>
      <li>
      <b>regexStr:</b>   \(.*\)
      </li>
      </ul>
      <b>Expected Result:</b>  (parenthesis match test)<br/><br/>
      <xsl:variable name="matchString" select="string('ignore (parenthesis match test) ignore')"/>
      <xsl:variable name="regexStr" select="string('\(.*\)')"/>
      <xsl:variable name="expected" select="string('(parenthesis match test)')"/>
      <xsl:variable name="resval" select="viv:match($matchString,$regexStr,'i')"/>
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
            <b>vivMatch-9:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>vivMatch-9:  TEST FAILED</b>
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
