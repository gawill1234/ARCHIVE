<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">
<application name="vivStrToMixed" modified-by="gary_testing" max-elt-id="1"
  modified="1209666370"
>
  <print><![CDATA[content-type:text/html


]]></print>
  <print>
    <parse encode="encode" filename="file://{viv:value-of('install_dir', 'option')}/data/vivStrToMixed.xml">
      <parser type="html-xsl"><![CDATA[

         <!-- <<<<<<<<<<<<<<<<<<<<< -->
         <xsl:output method="html" omit-xml-declaration="yes" indent="no" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>
   <xsl:template match="/">
      <html>
         <head>
            <xsl:call-template name="mysheet"/>
            <title>
               tryit
            </title>
         </head>
         <body>
            <p>
               <b>
                   version: <xsl:value-of select="viv:vivisimo-version()" />
               </b>
               <table border="1" align="center">
                  <xsl:call-template name="headRow"/>
                  <tbody>
                     <xsl:call-template name="doTest"/>
                  </tbody>
               </table>
            </p>
         </body>
      </html>
   </xsl:template>

   <xsl:template name="doTest">
      <xsl:variable name="junk" select="//testset/test" as="element()+"/>
      <xsl:for-each select="$junk">
         <tr>
            <xsl:variable name="testval" select="data"/>
            <xsl:variable name="expectval" select="expected"/>
            <xsl:variable name="argval" select="arguments"/>

            <!--  This next line is what we are actually testing -->
            <xsl:variable name="resval" select="viv:str-to-mixed($testval, false())"/>

            <td align="center">
               <i>
                  <xsl:value-of select="$testval"/>
               </i>
            </td>
            <td align="center">
               <i>
                  <xsl:value-of select="$expectval"/>
               </i>
            </td>
            <td align="center">
               <i>
                  <xsl:value-of select="$resval"/>
               </i>
            </td>
            <td align="center">
               <i>
                  <xsl:choose>
                     <xsl:when test="contains($resval, $expectval)">
                        <PASS>
                        TEST PASSED
                        </PASS>
                     </xsl:when>
                     <xsl:when test="not(contains($resval, $expectval))">
                        <FAIL>
                        TEST FAILED
                        </FAIL>
                     </xsl:when>
                  </xsl:choose>
               </i>
            </td>
         </tr>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="headRow">
      <caption>
         <i><b>
         Test results for viv:str-to-mixed()
         </b></i>
      </caption>
      <tr>
         <th>
            <b>
            Test Value
            </b>
         </th>
         <th>
            <b>
            Expected Value
            </b>
         </th>
         <th>
            <b>
            Result
            </b>
         </th>
         <th>
            <b>
            PASS/FAIL
            </b>
         </th>
      </tr>
   </xsl:template>

   <xsl:include href="../../data/sheet.xsl"/>

      ]]></parser>
    </parse>
    <fetch timeout="10000" finish="finish" />
  </print>
</application>
</vce>
