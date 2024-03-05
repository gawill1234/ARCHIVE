<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

   <xsl:template name="headRowA">
      <xsl:param name="funcname"/>
      <caption>
         <i><b>
         <xsl:value-of select="$funcname"/>
         </b></i>
      </caption>
      <tr>
         <th>
            <b>
            Test Expression
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

   <xsl:template name="headRowB">
      <xsl:param name="funcname"/>
      <caption>
         <b><i>
         <xsl:value-of select="$funcname"/>
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

