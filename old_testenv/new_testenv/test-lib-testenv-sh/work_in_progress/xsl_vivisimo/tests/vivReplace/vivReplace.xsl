<?xml version="1.0"?>


         <!-- <?xml version="1.0"?> -->
         <xsl:stylesheet version="1.0"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:viv='http://vivisimo.com/exslt'
         >

            <xsl:include href="../../includes/docstart.xsl"/>
            <xsl:include href="../../includes/passfail.xsl"/>
            <xsl:include href="../../includes/sheet.xsl"/>
            <xsl:include href="../../includes/restab.xsl"/>

            <xsl:template match="/">
               <xsl:call-template name="docstartA">

      <xsl:with-param name="functionName" select="string('vivReplace08 -- vivReplace(): regex substring replacement, different cases multiple matches')"/>

              </xsl:call-template>
      

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
      
      <tr>
         <td align="center">
            <i>
      string1
            </i>
         </td>
         <td align="center">
            <i>
      The Quick Brown fox jumps over the quick lazy dog
            </i>
         </td>
         <td align="center">
            <i>
      string
            </i>
         </td>
      </tr>
      
      <tr>
         <td align="center">
            <i>
      string2
            </i>
         </td>
         <td align="center">
            <i>
      q[uv][hi]ck
            </i>
         </td>
         <td align="center">
            <i>
      string
            </i>
         </td>
      </tr>
      
      <tr>
         <td align="center">
            <i>
      string3
            </i>
         </td>
         <td align="center">
            <i>
      slow
            </i>
         </td>
         <td align="center">
            <i>
      string
            </i>
         </td>
      </tr>
      
      </table>
      <!-- ============================  -->
      <!--  End of variable table        -->
      <!-- ============================  -->
      <!--  End generated code           -->
      
            </xsl:template>

            <xsl:template name="doTest">
               <xsl:variable name="junk" select="testset/test" as="element()+"/>
               <xsl:for-each select="$junk">
                  <tr>

      
                     <!--   Begin generated code -->
                  <xsl:variable name="string1" select="string('The Quick Brown fox jumps over the quick lazy dog')" as="xs:string"/>
      <xsl:variable name="string2" select="string('q[uv][hi]ck')" as="xs:string"/>
      <xsl:variable name="string3" select="string('slow')" as="xs:string"/>
      
                     <!--   End generated code -->

                  
                     <!--   Begin generated code -->
                  <xsl:variable name="expected" select="string('The slow Brown fox jumps over the slow lazy dog')" as="xs:string"/>
      
                     <!--   End generated code -->

                  
                     <td align="center">
                        <i>
      viv:replace($string1,$string2,$string3,'gi')
            
                        </i>
                     </td>
                     <td align="center">
                        <i>
                           <xsl:value-of select="$expected"/>
                        </i>
                     </td>

      
                     <!--   Begin generated code -->
                  <xsl:variable name="resval" select="viv:replace($string1,$string2,$string3,'gi')"/>
            
                     <!--   End generated code -->

                  

                     <xsl:call-template name="PassFail">
                        <xsl:with-param name="result" select="$resval"/>
                        <xsl:with-param name="expect" select="$expected"/>
                     </xsl:call-template>
                  </tr>
               </xsl:for-each>
      
            </xsl:template>
         </xsl:stylesheet>

      
