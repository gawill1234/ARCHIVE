<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

   <xsl:template name="docstartA">
      <xsl:param name="functionName"/>
      <html>
         <head>
            <xsl:call-template name="mysheet"/>
            <title>
               Test Results
            </title>
         </head>
         <body>
            <p align="center">
               <!-- <b>  -->
               <!--     version: <xsl:value-of select="viv:vivisimo-version()" />  -->
               <!-- </b>  -->
               <zz>
               ==============================================================
               </zz>
               <br/><br/>
               <xsl:call-template name="resTableHead">
                  <xsl:with-param name="funcname" select="$functionName"/>
               </xsl:call-template>
               <xsl:call-template name="doTest"/>
               <xsl:call-template name="resTableTail"/>
            </p>
         </body>
      </html>
   </xsl:template>

   <xsl:template name="docstartB">
      <xsl:param name="functionName"/>
      <html>
         <head>
            <xsl:call-template name="mysheet"/>
            <title>
               tryit
            </title>
         </head>
         <body>
            <p>
               <!-- <b>  -->
               <!--     version: <xsl:value-of select="viv:vivisimo-version()" />  -->
               <!-- </b>  -->
               <table border="1" align="center">
                  <xsl:call-template name="headRowB">
                     <xsl:with-param name="funcname" select="$functionName"/>
                  </xsl:call-template>
                  <tbody>
                     <xsl:call-template name="doTest"/>
                  </tbody>
               </table>
            </p>
         </body>
      </html>
   </xsl:template>

</xsl:stylesheet>

