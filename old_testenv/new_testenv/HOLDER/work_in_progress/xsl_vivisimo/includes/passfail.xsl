<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

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
               <xsl:when test="contains(normalize-space($result), normalize-space($expect))">
                  <PASS>
                  TEST PASSED
                  </PASS>
               </xsl:when>
               <xsl:when test="not(contains(normalize-space($result), normalize-space($expect)))">
                  <FAIL>
                  TEST FAILED
                  </FAIL>
               </xsl:when>
            </xsl:choose>
         </i>
      </td>
   </xsl:template>

</xsl:stylesheet>

