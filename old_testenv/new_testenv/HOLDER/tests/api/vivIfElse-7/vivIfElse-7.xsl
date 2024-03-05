<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivIfElse-7" modified-by="gary_testing" max-elt-id="1"
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
         vivIfElse-7
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      vivIfElse-7
      </font>
      <br/><br/>
      <b>Description:</b>  Test of unequal function condition<br/><br/>
      <b>Function:</b>  viv:if-else($myint1 = $myint2,'TRUE', 'FALSE')<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>myint1:</b>   false()
      </li>
      <li>
      <b>myint2:</b>   true()
      </li>
      </ul>
      <b>Expected Result:</b>  FALSE<br/><br/>
      <xsl:variable name="myint1" select="false()" as="xs:boolean"/>
      <xsl:variable name="myint2" select="true()" as="xs:boolean"/>
      <xsl:variable name="expected" select="string('FALSE')"/>
      <xsl:variable name="resval" select="viv:if-else($myint1 = $myint2,'TRUE', 'FALSE')"/>
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
            <b>vivIfElse-7:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>vivIfElse-7:  TEST FAILED</b>
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