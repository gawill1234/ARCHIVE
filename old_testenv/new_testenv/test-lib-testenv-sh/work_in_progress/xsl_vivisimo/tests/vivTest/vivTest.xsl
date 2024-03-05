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

      <xsl:with-param name="functionName" select="string('vivTest04 -- vivTest(): simple string, no match')"/>

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
      Habitat destroyed, the wolves took to snorting quack
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
      .*qu[ia]ck
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
                  <xsl:variable name="string1" select="string('Habitat destroyed, the wolves took to snorting quack')" as="xs:string"/>
      <xsl:variable name="string2" select="string('.*qu[ia]ck')" as="xs:string"/>
      
                     <!--   End generated code -->

                  
                     <!--   Begin generated code -->
                  <xsl:variable name="expected" select="true()"/>
      
                     <!--   End generated code -->

                  
                     <td align="center">
                        <i>
      viv:test($string1,$string2,'regex')
            
                        </i>
                     </td>
                     <td align="center">
                        <i>
                           <xsl:value-of select="$expected"/>
                        </i>
                     </td>

      
                     <!--   Begin generated code -->
                  <xsl:variable name="resval" select="viv:test($string1,$string2,'regex')"/>
            
                     <!--   End generated code -->

                  

                     <xsl:call-template name="PassFail">
                        <xsl:with-param name="result" select="$resval"/>
                        <xsl:with-param name="expect" select="$expected"/>
                     </xsl:call-template>
                  </tr>
               </xsl:for-each>
      
            </xsl:template>
         </xsl:stylesheet>

      
