<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivChoose-3" modified-by="gary_testing" max-elt-id="1"
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
         vivChoose-3
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      vivChoose-3
      </font>
      <br/><br/>
      <b>Description:</b>  vivChoose04 -- vivChoose(): First two choices are true<br/><br/>
      <b>Function:</b>  viv:choose(true(),$condA,true(),$condB,$condDefault)<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>condA:</b>   ConditionA
      </li>
      <li>
      <b>condB:</b>   ConditionB
      </li>
      <li>
      <b>condDefault:</b>   DEFAULT
      </li>
      </ul>
      <b>Expected Result:</b>  ConditionA<br/><br/>
      <xsl:variable name="condA" select="string('ConditionA')"/>
      <xsl:variable name="condB" select="string('ConditionB')"/>
      <xsl:variable name="condDefault" select="string('DEFAULT')"/>
      <xsl:variable name="expected" select="string('ConditionA')"/>
      <xsl:variable name="resval" select="viv:choose(true(),$condA,true(),$condB,$condDefault)"/>
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
            <b>vivChoose-3:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>vivChoose-3:  TEST FAILED</b>
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