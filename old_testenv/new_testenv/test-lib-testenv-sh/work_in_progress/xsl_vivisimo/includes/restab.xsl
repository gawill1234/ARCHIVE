<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

   <xsl:template name="resTableHead">
      <xsl:param name="funcname"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[

      <!-- ============================  -->
      <!--  Beginning of results table   -->
      <!-- ============================  -->

      <table border="1" align="center">
      <caption>
         <i><b>
      ]]></xsl:text>

         <xsl:value-of select="$funcname"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[
         </b></i>
      </caption>
      <tr>
      <th><b>
            Test Expression
            </b></th>
      <th><b>
            Expected Value
            </b></th>
      <th><b>
            Result
            </b></th>
      <th><b>
            PASS/FAIL
            </b></th>
      </tr>
      <tbody>
      ]]></xsl:text>

   </xsl:template>

   <xsl:template name="resTableValue">
      <xsl:param name="varName"/>
      <xsl:param name="varValue"/>
      <xsl:param name="varType"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[
      <tr>
         <td align="center">
            <i>
      ]]></xsl:text>

               <xsl:value-of select="$varName"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[
            </i>
         </td>
         <td align="center">
            <i>
      ]]></xsl:text>

               <xsl:value-of select="$varValue"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[
            </i>
         </td>
         <td align="center">
            <i>
      ]]></xsl:text>

               <xsl:value-of select="$varType"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[
            </i>
         </td>
      </tr>
      ]]></xsl:text>
   </xsl:template>

   <xsl:template name="resTableTail">
      <xsl:text disable-output-escaping="yes"><![CDATA[
         </tbody>
      </table>
      <!-- ============================  -->
      <!--  End of results table         -->
      <!-- ============================  -->
      ]]></xsl:text>
   </xsl:template>

</xsl:stylesheet>
