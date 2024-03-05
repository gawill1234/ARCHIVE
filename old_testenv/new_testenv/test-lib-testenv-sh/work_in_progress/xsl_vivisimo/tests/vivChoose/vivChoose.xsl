<?xml version="1.0"?>


         <!-- <?xml version="1.0"?> -->
         <xsl:stylesheet version="1.0"
           xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
           xmlns:viv='http://vivisimo.com/exslt'
         >

            <xsl:include href="./include/docstart.xsl"/>
            <xsl:include href="./include/passfail.xsl"/>
            <xsl:include href="./include/sheet.xsl"/>
            <xsl:include href="./include/restab.xsl"/>

            <xsl:template match="/">
               <xsl:call-template name="docstartA">

      <xsl:with-param name="functionName" select="string('vivChoose08 -- vivChoose(): Default is returned when it is the only case')"/>

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
      condDefault
            </i>
         </td>
         <td align="center">
            <i>
      DEFAULT
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
                  <xsl:variable name="condDefault" select="string('DEFAULT')" as="xs:string"/>
      
                     <!--   End generated code -->

                  
                     <!--   Begin generated code -->
                  <xsl:variable name="expected" select="string('DEFAULT')" as="xs:string"/>
      
                     <!--   End generated code -->

                  
                     <td align="center">
                        <i>
      viv:choose($condDefault)
            
                        </i>
                     </td>
                     <td align="center">
                        <i>
                           <xsl:value-of select="$expected"/>
                        </i>
                     </td>

      
                     <!--   Begin generated code -->
                  <xsl:variable name="resval" select="viv:choose($condDefault)"/>
            
                     <!--   End generated code -->

                  

                     <xsl:call-template name="PassFail">
                        <xsl:with-param name="result" select="$resval"/>
                        <xsl:with-param name="expect" select="$expected"/>
                     </xsl:call-template>
                  </tr>
               </xsl:for-each>
      
            </xsl:template>
         </xsl:stylesheet>

      
