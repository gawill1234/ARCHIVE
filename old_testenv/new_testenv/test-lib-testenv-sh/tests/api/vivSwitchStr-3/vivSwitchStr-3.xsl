<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivSwitchStr-3" modified-by="gary_testing" max-elt-id="1"
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
         SwitchStr-3
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      vivSwitchStr-3
      </font>
      <br/><br/>
      <b>Description:</b>  simple string match<br/><br/>
      <b>Function:</b>  viv:switch-string('NO-MATCHES',$other1,'wrong',$matchIt,$matchIt,$other2,'wrong','No-match','wrong',$condDefault)<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>other1:</b>   OTHER1
      </li>
      <li>
      <b>other2:</b>   OTHER2
      </li>
      <li>
      <b>condDefault:</b>   DEFAULT
      </li>
      <li>
      <b>matchIt:</b>   MATCHED
      </li>
      </ul>
      <b>Expected Result:</b>  DEFAULT<br/><br/>

      <xsl:variable name="matchIt" select="string('MATCHED')"/>
      <xsl:variable name="other1" select="string('OTHER1')"/>
      <xsl:variable name="other2" select="string('OTHER2')"/>
      <xsl:variable name="condDefault" select="string('DEFAULT')"/>
      <xsl:variable name="expected" select="string('DEFAULT')"/>

      <xsl:variable name="resval" select="viv:switch-string('NO-MATCHES',$other1,'wrong',$matchIt,$matchIt,$other2,'wrong','No-match','wrong',$condDefault)"/>
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
            <b>vivSwitchStr-3:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>SwitchStr-3:  TEST FAILED</b>
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
