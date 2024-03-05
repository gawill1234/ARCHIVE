<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="fileStat-2" modified-by="gary_testing" max-elt-id="1"
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
         fileStat-2
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      fileStat-2
      </font>
      <br/><br/>
      <b>Description:</b>  Pure xsl data getter<br/><br/>
      <b>Function:</b>  file:stat('../../data/repository.xml')<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>file:</b>   ../../data/repository.xml
      </li>
      </ul>
      <b>Expected Result:</b>  2196<br/><br/>
      <xsl:variable name="file1" select="string('../../data/repository.xml')"/>
      <xsl:variable name="expected" select="string('2196')"/>
      <xsl:variable name="resval" select="file:stat($file1)/size"/>
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
            <b>fileStat-2:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>fileStat-2:  TEST FAILED</b>
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
