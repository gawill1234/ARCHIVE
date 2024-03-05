<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivNodeToStr-3" modified-by="gary_testing" max-elt-id="1"
  modified="1209666370"
>
  <print><![CDATA[content-type:text/html

    
]]></print>
  <print>
    <parse encode="encode" filename="file://{viv:value-of('install_dir', 'option')}/data/nodes.xml">
      <parser type="html-xsl"><![CDATA[

         <!-- <<<<<<<<<<<<<<<<<<<<< -->
         <xsl:output method="html" omit-xml-declaration="yes" indent="no" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
   <xsl:template match="/">
      <html>
      <title>
         vivNodeToStr-3
      </title>
      <body>

      <b>TEST ID:</b>
      <font color="red">
      vivNodeToStr-3
      </font>
      <br/><br/>
      <b>Description:</b>  vivNodeToStr-3 -- Multiple second level nodes<br/><br/>
      <b>Function:</b>  viv:node-to-str($testNode,true())<br/><br/>
      <b>Variable Values:</b>
      <ul>
      <li>
      <b>testNode:</b>   testnode3
      </li>
      </ul>
      <b>Expected Result:</b>  &lt;testnode3&gt; &lt;name&gt; dummy &lt;/name&gt; &lt;whatrot&gt; rotplace &lt;/whatrot&gt; &lt;/testnode3&gt;<br/><br/>

      <xsl:variable name="junk" select="//testset/test" as="element()+"/>

      <xsl:for-each select="$junk">

         <xsl:variable name="testNode" select="testnode3"/>
         <xsl:variable name="expected" select="string('&lt;testnode3&gt; &lt;name&gt; dummy &lt;/name&gt; &lt;whatrot&gt; rotplace &lt;/whatrot&gt; &lt;/testnode3&gt;')"/>

         <xsl:variable name="resval" select="viv:node-to-str($testNode,true())"/>
         <xsl:call-template name="PassFail">
            <xsl:with-param name="result" select="$resval"/>
            <xsl:with-param name="expect" select="$expected"/>
         </xsl:call-template>
      </xsl:for-each>

      </body>
      </html>
   </xsl:template>

   <xsl:template name="PassFail">
      <xsl:param name="result"/>
      <xsl:param name="expect"/>
      <b>Actual Result:</b>
      <xsl:value-of select="normalize-space($result)"/>
      <br/>
      <xsl:choose>
         <xsl:when test="contains(normalize-space($result), normalize-space($expect))">
            <br/>
            <font color="green">
            <b>vivNodeToStr-3:  TEST PASSED</b>
            </font>
            <br/>
         </xsl:when>
         <xsl:otherwise>
            <br/>
            <font color="red">
            <b>vivNodeToStr-3:  TEST FAILED</b>
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
