<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:viv='http://vivisimo.com/exslt'
>

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
                  <caption>
                     <i><b>
                     Test results for viv:parse-date()
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
                        Format Arg
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
                  <tbody>
                  <xsl:variable name="junk" select="testset/test" as="element()+"/>
                  <xsl:for-each select="$junk">
                     <tr>
                        <xsl:variable name="testval" select="normalize-space(data)"/>
                        <xsl:variable name="expectval" select="normalize-space(expected)"/>
                        <xsl:variable name="argsval" select="normalize-space(argument1)"/>

                        <td align="center">
                           <i>
                           <xsl:if test="string($testval) = ''">
                              <xsl:text>Empty</xsl:text>
                           </xsl:if>
                           <xsl:if test="string($testval) != ''">
                              <xsl:value-of select="string($testval)"/>
                           </xsl:if>
                           </i>
                        </td>
                        <td align="center">
                           <i>
                           <xsl:if test="string($argsval) = ''">
                              <xsl:text>Empty</xsl:text>
                           </xsl:if>
                           <xsl:if test="string($argsval) != ''">
                              <xsl:value-of select="string($argsval)"/>
                           </xsl:if>
                           </i>
                        </td>
                        <td align="center">
                           <i>
                              <xsl:value-of select="$expectval"/>
                           </i>
                        </td>
                        <!--  This line is what we are actually testing -->
                        <xsl:variable name="resval" select="viv:parse-date(string($testval), string($argsval))"/>
                        <xsl:call-template name="PassFail">
                           <xsl:with-param name="result" select="$resval"/>
                           <xsl:with-param name="expect" select="$expectval"/>
                        </xsl:call-template>
                     </tr>
                  </xsl:for-each>
                  </tbody>
               </table>
            </p>
         </body>
      </html>
   </xsl:template>

   <xsl:template name="PassFail">
      <xsl:param name="result"/>
      <xsl:param name="expect"/>
      <td align="center">
         <i>
            <xsl:value-of select="$result"/>
         </i>
      </td>
      <td align="center">
         <i>
            <xsl:choose>
               <xsl:when test="normalize-space($result) = normalize-space($expect)">
                  <PASS>
                  TEST PASSED
                  </PASS>
               </xsl:when>
               <xsl:when test="not(normalize-space($result) = normalize-space($expect))">
                  <FAIL>
                  TEST FAILED
                  </FAIL>
               </xsl:when>
            </xsl:choose>
         </i>
      </td>
   </xsl:template>

   <xsl:include href="includes/sheet.xsl"/>

</xsl:stylesheet>

