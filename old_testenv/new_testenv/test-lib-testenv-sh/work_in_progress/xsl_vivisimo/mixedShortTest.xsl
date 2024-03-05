<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:viv='http://vivisimo.com/exslt'
>

   <xsl:template match="/">
      <html>
         <head>
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
      <xsl:variable name="junk" select="testset/test" as="element()+"/>
      <xsl:for-each select="$junk">
         <tr>
            <xsl:variable name="testval" select="data"/>
            <xsl:variable name="expectval" select="expected"/>

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
                        TEST PASSED
                     </xsl:when>
                     <xsl:when test="not(contains($resval, $expectval))">
                        TEST FAILED
                     </xsl:when>
                  </xsl:choose>
               </i>
            </td>
         </tr>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="headRow">
      <caption>
         <b><i>
         Test results for viv:str-to-mixed()
         </i></b>
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


</xsl:stylesheet>

