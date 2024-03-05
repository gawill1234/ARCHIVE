<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:viv='http://vivisimo.com/exslt'
     xmlns:date="http://exslt.org/dates-and-times"
     xmlns:lxslt="http://xml.apache.org/xslt"
     extension-element-prefixes="date"
>

   <xsl:template name="mysheet">
      <style type="text/css">
         b  {
               color:black;
               font-family:arial;
               font-size:90%;
               font-style:bold;
            }
         i  {
               color:black;
               font-family:arial;
               font-size:70%;
               font-style:italic;
            }
         i b  {
               color:black;
               font-size:110%;
               font-style:bold;
               font-family:arial;
            }
         zz  {
               color:grey;
               font-size:100%;
               font-style:bold;
            }
         novar  {
               color:purple;
               font-family:arial;
               font-size:70%;
               font-style:italic;
            }
         PASS  {
               color:green;
               font-size:90%;
               font-style:bold;
            }
         FAIL  {
               color:red;
               font-size:90%;
               font-style:bold;
            }
      </style>

   </xsl:template>


   <xsl:template name="for.loop"> 
      <xsl:param name="i" /> 
      <xsl:param name="count" /> 
      <xsl:param name="testval" /> 
      <xsl:param name="stem" /> 
      <xsl:param name="kb" /> 
      <xsl:param name="seg" /> 
      <!--begin_: Line_by_Line_Output --> 
      <xsl:if test="$i &lt;= $count"> 
         <xsl:variable name="resval" select="viv:stem-kb-key(string($testval), string($stem), string($kb), string($seg))"/>
      </xsl:if> 

      <!--begin_: RepeatTheLoopUntilFinished--> 
      <xsl:if test="$i &lt;= $count"> 
         <xsl:call-template name="for.loop"> 
            <xsl:with-param name="i"> 
            <xsl:value-of select="$i + 1"/> 
            </xsl:with-param> 
            <xsl:with-param name="count"> 
            <xsl:value-of select="$count"/> 
            </xsl:with-param> 
            <xsl:with-param name="testval"> 
            <xsl:value-of select="$testval"/> 
            </xsl:with-param> 
            <xsl:with-param name="stem"> 
            <xsl:value-of select="$stem"/> 
            </xsl:with-param> 
            <xsl:with-param name="kb"> 
            <xsl:value-of select="$kb"/> 
            </xsl:with-param> 
            <xsl:with-param name="seg"> 
            <xsl:value-of select="$seg"/> 
            </xsl:with-param> 
         </xsl:call-template> 
      </xsl:if> 

   </xsl:template> 



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
                     Test results for viv:stem-kb-key()
                     </b></i>
                  </caption>
                  <tr>
                     <th>
                        <b>
                        Stems Created
                        </b>
                     </th>
<!--
                     <th>
                        <b>
                        Segmenter
                        </b>
                     </th>
                     <th>
                        <b>
                        Stemmers
                        </b>
                     </th>
                     <th>
                        <b>
                        Knowledge Base
                        </b>
                     </th>
                     <th>
                        <b>
                        Test Data
                        </b>
                     </th>
                     <th>
                        <b>
                        Begin
                        </b>
                     </th>
                     <th>
                        <b>
                        End
                        </b>
                     </th>
-->
                     <th>
                        <b>
                        Elapsed (ms)
                        </b>
                     </th>
                  </tr>
                  <tbody>
                  <xsl:variable name="junk" select="testset/test" as="element()+"/>
                  <xsl:for-each select="$junk">
                     <tr>
                        <xsl:variable name="testval" select="normalize-space(data)"/>
                        <xsl:variable name="seg" select="normalize-space(segmenter)"/>
                        <xsl:variable name="stem" select="normalize-space(stemmer)"/>
                        <xsl:variable name="kb" select="normalize-space(kb)"/>

                        <xsl:variable name="resval" select="viv:stem-kb-key(string($testval), string($stem), string($kb), string($seg))"/>
                        <td align="center">
                           <i>
                           <xsl:if test="string($resval) = ''">
                              <xsl:text>Empty</xsl:text>
                           </xsl:if>
                           <xsl:if test="string($resval) != ''">
                              <xsl:value-of select="string($resval)"/>
                           </xsl:if>
                           </i>
                        </td>
<!--
                        <td align="center">
                           <i>
                              <xsl:value-of select="$seg"/>
                           </i>
                        </td>
                        <td align="center">
                           <i>
                              <xsl:value-of select="$stem"/>
                           </i>
                        </td>
                        <td align="center">
                           <i>
                              <xsl:value-of select="$kb"/>
                           </i>
                        </td>
-->
                        <!--  This line is what we are actually testing -->
                        <!--  string, stemmers, kbs, segmenters -->
<!--  -->
                        <xsl:variable name="starttime" select='date:seconds()'/>
                        <xsl:call-template name="for.loop"> 
                           <xsl:with-param name="i">1</xsl:with-param> 
                           <xsl:with-param name="count">1000</xsl:with-param> 
                           <xsl:with-param name="testval"> 
                           <xsl:value-of select="$testval"/> 
                           </xsl:with-param> 
                           <xsl:with-param name="stem"> 
                           <xsl:value-of select="$stem"/> 
                           </xsl:with-param> 
                           <xsl:with-param name="kb"> 
                           <xsl:value-of select="$kb"/> 
                           </xsl:with-param> 
                           <xsl:with-param name="seg"> 
                           <xsl:value-of select="$seg"/> 
                           </xsl:with-param> 
                        </xsl:call-template>
                        <xsl:variable name="endtime" select='date:seconds()'/>
<!--
                        <td align="center">
                           <i>
                              <xsl:value-of select="$testval"/>
                           </i>
                        </td>
                        <td align="center">
                           <i>
                              <xsl:value-of select="$starttime"/>
                           </i>
                        </td>
                        <td align="center">
                           <i>
                              <xsl:value-of select="$endtime"/>
                           </i>
                        </td>
-->
                        <td align="center">
                           <i>
                              <xsl:value-of select="$endtime - $starttime"/>
                              <!-- <xsl:value-of select="($endtime - $starttime) * .001"/> -->
                              <!-- <xsl:value-of select="date:difference($starttime, $endtime)"/> -->
                           </i>
                        </td>
                     </tr>
                  </xsl:for-each>
                  </tbody>
               </table>
            </p>
         </body>
      </html>
   </xsl:template>

</xsl:stylesheet>

