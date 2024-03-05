<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<macro name="query-meta-cgi-parameters" modified-by="pesenti@vivisimo"
  max-elt-id="53" modified="1209443600"
>
  <expand-macro name="cgi-parameters-load" />

  <if-var name="v:debug" realm="state-param">
    <option name="debug" value="true" />
  </if-var>

  <if-var name="v:profile" realm="state-param">
    <option name="profile" value="true" />
  </if-var>

  <if test="not(viv:value-of('v:file','state-param'))">
    <for-each
      select="viv:url-decompose-query(viv:value-of('QUERY_STRING','env'))" as="param"
    >
      <param name="{$param/@name}" value="{$param/@value}" />
    </for-each>
  </if>
</macro>

<macro name="cgi-parameters-load" modified-by="goulding@Vivisimo" max-elt-id="10"
  modified="1208455422"
>

  <for-each select="viv:url-decompose-query(viv:value-of('QUERY_STRING','env'))"
    as="param"
  >
    <state-param name="{$param/@name}" value="{$param/@value}" />
  </for-each>

</macro>

<application name="fileDelete-1" modified-by="gary_testing" max-elt-id="1"
  modified="1209666370"
>
  <expand-macro name="query-meta-cgi-parameters" />

  <declare name="myfile" />
  <set-var name="myfile" value="{normalize-space(viv:value-of('filename','param'))}" />

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
         fileDelete-1
      </title>
      <body>
      <b>TEST ID:</b>
      <font color="red">
      fileDelete-1
      </font>
      <br/><br/>
      <b>Description:</b>  Delete non-existent file<br/><br/>
      <b>Function:</b>  file:delete($file1)<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>file1:</b>   <xsl:value-of select="$myfile"/>
      </li>
      </ul>
      <b>Expected Result:</b>  false<br/><br/>
      <xsl:variable name="file1" select="$myfile"/>
      <xsl:variable name="expected" select="false()"/>
      <xsl:variable name="resval" select="file:delete($file1)"/>
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
            <b>fileDelete-1:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>fileDelete-1:  TEST FAILED</b>
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
