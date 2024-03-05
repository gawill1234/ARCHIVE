<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

   <xsl:template name="varTableHead">

      <xsl:text disable-output-escaping="yes"><![CDATA[

      <!--  Begin generated code         -->
      <!-- ============================  -->
      <!--  Beginning of variable table  -->
      <!-- ============================  -->
      <table border="1" align="center">
      <caption><i><b>Variables</b></i></caption>
      <tr>
      <th><b>
            Variable Name
            </b></th>
      <th><b>
            Variable Value
            </b></th>
      <th><b>
            Variable Type
            </b></th>
      </tr>
      ]]></xsl:text>

   </xsl:template>

   <xsl:template name="varTableEmpty">
      <xsl:text disable-output-escaping="yes"><![CDATA[
      <tr>
         <td align="center">
            <novar>
               No test variables
            </novar>
         </td>
         <td align="center">
            <i>
               N/A
            </i>
         </td>
         <td align="center">
            <i>
               N/A
            </i>
         </td>
      </tr>
      ]]></xsl:text>
   </xsl:template>

   <xsl:template name="varTableValue">
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

   <xsl:template name="varTableTail">
      <xsl:text disable-output-escaping="yes"><![CDATA[
      </table>
      <!-- ============================  -->
      <!--  End of variable table        -->
      <!-- ============================  -->
      <!--  End generated code           -->
      ]]></xsl:text>
   </xsl:template>

</xsl:stylesheet>
