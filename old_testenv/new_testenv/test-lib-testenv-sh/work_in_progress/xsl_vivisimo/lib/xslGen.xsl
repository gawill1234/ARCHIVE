<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:dyn='http://exslt.org/dynamic'
>
   <xsl:include href="../includes/vartab.xsl"/>
   <xsl:include href="../includes/restab.xsl"/>

   <!--   ###################################################################  -->
   <xsl:template name="underTest">
      <!--  =======================   -->
      <!--  This template generates a line of xsl that looks like:  -->
      <!--     funcname(arg1, arg2, ...)  -->
      <!--  It is a table entry which describes what is being tested. -->
      <!--  Example:  -->
      <!--     viv:if-else(true(), 'TRUE', 'FALSE')  -->
      <!--  =======================   -->

      <!--  =======================   -->
      <!--  Initialize the template.   Get the number of arguments  -->
      <!--  and the trailer for the xsl line that is being generated -->
      <!--  =======================   -->
      <xsl:variable name="argcnt" select="count(argument)"/>

      <!--  =======================   -->
      <!--  Set up the first part of the xsl line, up the the name of  -->
      <!--  the function and the opening "("  -->
      <!--  =======================   -->
      <xsl:value-of select="normalize-space(funcname)"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[(]]></xsl:text>

      <xsl:for-each select="argument">
         <!--  =======================   -->
         <!--  For each function argument, output the value taking into account  -->
         <!--  type of value it is (function, variable, number, string, etc)  -->
         <!--  =======================   -->
         <xsl:call-template name="processArg">
            <xsl:with-param name="argname" select="normalize-space(value)"/>
            <xsl:with-param name="argtype" select="normalize-space(type)"/>
         </xsl:call-template>
         <!--  =======================   -->
         <!--  If this is not the last argument, put in a ","  -->
         <!--  argument seperator  -->
         <!--  =======================   -->
         <xsl:if test="position() &lt; $argcnt">
            <xsl:text disable-output-escaping="yes"><![CDATA[,]]></xsl:text>
         </xsl:if>
         <!--  =======================   -->
         <!--  If this is the last argument, put in a ")"  -->
         <!--  function argument list termination  -->
         <!--  =======================   -->
         <xsl:if test="position() >= $argcnt">
            <xsl:text disable-output-escaping="yes"><![CDATA[)]]>
            </xsl:text>
         </xsl:if>
      </xsl:for-each>

   </xsl:template>

   <!--   ###################################################################  -->

   <!--   ###################################################################  -->
   <!--  =======================   -->
   <!--  The templates which are output to make  -->
   <!--  up a single test.xsl file.  -->
   <!--  =======================   -->

   <xsl:template name="fTemplateLev3A">

      <xsl:text disable-output-escaping="yes"><![CDATA[

                     <xsl:call-template name="PassFail">
                        <xsl:with-param name="result" select="$resval"/>
                        <xsl:with-param name="expect" select="$expected"/>
                     </xsl:call-template>
                  </tr>
               </xsl:for-each>
      ]]></xsl:text>

   </xsl:template>

   <xsl:template name="fTemplateLev4A">

      <xsl:text disable-output-escaping="yes"><![CDATA[
            </xsl:template>
         </xsl:stylesheet>

      ]]></xsl:text>

   </xsl:template>

   <xsl:template name="fTemplateLev2A">


      <xsl:text disable-output-escaping="yes"><![CDATA[
                     <td align="center">
                        <i>
      ]]></xsl:text>
                           <xsl:call-template name="underTest"/>

                           <!-- <xsl:value-of select="string('NOVALUE YET')"/> -->

      <xsl:text disable-output-escaping="yes"><![CDATA[
                        </i>
                     </td>
                     <td align="center">
                        <i>
                           <xsl:value-of select="$expected"/>
                        </i>
                     </td>

      ]]></xsl:text>

   </xsl:template>

   <xsl:template name="fTemplateLev1A">

      <xsl:text disable-output-escaping="yes"><![CDATA[

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

      ]]></xsl:text>

      <xsl:text disable-output-escaping="yes"><![CDATA[<]]></xsl:text>

      <xsl:variable name="funcCall" select="string('xsl:with-param name=&quot;functionName&quot; select=&quot;string(')"/>
      <xsl:variable name="captionLine" select="concat(normalize-space(name), ' -- ',
                                                  normalize-space(description))"/>
      <xsl:variable name="funcCall2" select="string(')&quot;/')"/>

      <xsl:value-of select="$funcCall"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
      <xsl:value-of select="$captionLine"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
      <xsl:value-of select="$funcCall2"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[>]]></xsl:text>

      <xsl:text disable-output-escaping="yes"><![CDATA[

              </xsl:call-template>
      ]]></xsl:text>

      <xsl:call-template name="varTableHead"/>
      <xsl:variable name="vrct" select="count(variable)" as="xs:integer"/>
      <xsl:if test="$vrct > 0">
         <xsl:for-each select="variable">
            <xsl:call-template name="varTableValue">
               <xsl:with-param name="varName" select="normalize-space(name)"/>
               <xsl:with-param name="varValue" select="normalize-space(value)"/>
               <xsl:with-param name="varType" select="normalize-space(type)"/>
            </xsl:call-template>
         </xsl:for-each>
      </xsl:if>
      <xsl:if test="$vrct &lt;= 0">
         <xsl:call-template name="varTableEmpty"/>
      </xsl:if>
      <xsl:call-template name="varTableTail"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[
            </xsl:template>

            <xsl:template name="doTest">
               <xsl:variable name="junk" select="testset/test" as="element()+"/>
               <xsl:for-each select="$junk">
                  <tr>

      ]]></xsl:text>

   </xsl:template>

   <!--   ###################################################################  -->
   <!--   ###################################################################  -->
   <xsl:template name="othervar">
      <xsl:param name="varname"/>
      <xsl:param name="varvalue"/>
      <xsl:param name="vartype"/>

      <xsl:variable name="front" select="concat('xsl:variable name=&quot;',
                                                  $varname, '&quot; select=&quot;')"/>

      <xsl:variable name="rear" select="string('&quot; as=&quot;xs:integer&quot;/')"/>
      <xsl:variable name="reardbl" select="string('&quot; as=&quot;xs:double&quot;/')"/>
      <xsl:variable name="rearflt" select="string('&quot; as=&quot;xs:float&quot;/')"/>
      <xsl:variable name="reardte" select="string('&quot; as=&quot;xs:date&quot;/')"/>
      <xsl:variable name="reardtime" select="string('&quot; as=&quot;xs:dateTime&quot;/')"/>
      <xsl:variable name="rearbool" select="string('&quot; as=&quot;xs:boolean&quot;/')"/>
      <xsl:variable name="reardec" select="string('&quot; as=&quot;xs:decimal&quot;/')"/>
      <xsl:variable name="rearqnm" select="string('&quot; as=&quot;xs:QName&quot;/')"/>
      <xsl:variable name="reartim" select="string('&quot; as=&quot;xs:time&quot;/')"/>
      <xsl:variable name="reartok" select="string('&quot; as=&quot;xs:token&quot;/')"/>
      <xsl:variable name="rearfun" select="string('&quot;/')"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[<]]></xsl:text>
      <xsl:value-of select="$front"/>
      <xsl:value-of select="$varvalue"/>
      <xsl:choose>
         <xsl:when test="$vartype = 'integer'">
            <xsl:value-of select="$rear"/>
         </xsl:when>
         <xsl:when test="$vartype = 'double'">
            <xsl:value-of select="$reardbl"/>
         </xsl:when>
         <xsl:when test="$vartype = 'float'">
            <xsl:value-of select="$rearflt"/>
         </xsl:when>
         <xsl:when test="$vartype = 'date'">
            <xsl:value-of select="$reardte"/>
         </xsl:when>
         <xsl:when test="$vartype = 'dateTime'">
            <xsl:value-of select="$reardtime"/>
         </xsl:when>
         <xsl:when test="$vartype = 'boolean'">
            <xsl:value-of select="$rearbool"/>
         </xsl:when>
         <xsl:when test="$vartype = 'decimal'">
            <xsl:value-of select="$reardec"/>
         </xsl:when>
         <xsl:when test="$vartype = 'QName'">
            <xsl:value-of select="$rearqnm"/>
         </xsl:when>
         <xsl:when test="$vartype = 'time'">
            <xsl:value-of select="$reartim"/>
         </xsl:when>
         <xsl:when test="$vartype = 'token'">
            <xsl:value-of select="$reartok"/>
         </xsl:when>
         <xsl:when test="$vartype = 'function'">
            <xsl:value-of select="$rearfun"/>
         </xsl:when>
         <xsl:when test="$vartype = 'node'">
            <xsl:value-of select="$rearfun"/>
         </xsl:when>
      </xsl:choose>
      <xsl:text disable-output-escaping="yes"><![CDATA[>]]>
      </xsl:text>
   </xsl:template>
   <!--   ###################################################################  -->

   <!--   ###################################################################  -->
   <xsl:template name="stringvar">
      <xsl:param name="varname"/>
      <xsl:param name="varvalue"/>

      <xsl:variable name="front" select="concat('xsl:variable name=&quot;',
                                                  $varname, '&quot; select=&quot;string(')"/>

      <xsl:variable name="rear" select="string(')&quot; as=&quot;xs:string&quot;/')"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[<]]></xsl:text>
      <xsl:value-of select="$front"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
      <xsl:value-of select="$varvalue"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
      <xsl:value-of select="$rear"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[>]]>
      </xsl:text>
   </xsl:template>
   <!--   ###################################################################  -->

   <!--   ###################################################################  -->
   <xsl:template name="variablelinecon">
      <xsl:param name="varname"/>
      <xsl:param name="varvalue"/>
      <xsl:param name="vartype"/>

      <xsl:choose>
         <xsl:when test="$vartype = 'string'">
            <xsl:call-template name="stringvar">
               <xsl:with-param name="varname" select="$varname"/>
               <xsl:with-param name="varvalue" select="$varvalue"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$vartype != 'string'">
            <xsl:call-template name="othervar">
               <xsl:with-param name="varname" select="$varname"/>
               <xsl:with-param name="varvalue" select="$varvalue"/>
               <xsl:with-param name="vartype" select="$vartype"/>
            </xsl:call-template>
         </xsl:when>
      </xsl:choose>
      
   </xsl:template>
   <!--   ###################################################################  -->

   <!--   ###################################################################  -->
   <xsl:template name="functionPart">
      <xsl:param name="varname"/>
      <xsl:param name="varvalue"/>
      <xsl:variable name="front" select="concat('xsl:variable name=&quot;',
                                                  $varname, '&quot; select=&quot;')"/>

      <xsl:text disable-output-escaping="yes"><![CDATA[<]]></xsl:text>
      <xsl:value-of select="$front"/><xsl:value-of select="$varvalue"/>
      <xsl:text disable-output-escaping="yes"><![CDATA[(]]></xsl:text>
   </xsl:template>

   <!--   ###################################################################  -->
   <xsl:template name="processArg">
      <!--  =======================   -->
      <!--  This template processes arguments by type  -->
      <!--  Example:  -->
      <!--     type string generates:    'argname'  -->
      <!--     type function generates:  argname()  -->
      <!--     type variable generates:  $argname  -->
      <!--     type number generates:    argname  -->
      <!--  =======================   -->
      <xsl:param name="argname"/>
      <xsl:param name="argtype"/>

      <xsl:if test="$argtype = 'variable'">
         <xsl:text disable-output-escaping="yes"><![CDATA[$]]></xsl:text>
         <xsl:value-of select="$argname"/>  
      </xsl:if>
      <xsl:if test="$argtype = 'function'">
         <xsl:value-of select="$argname"/>  
      </xsl:if>
      <xsl:if test="$argtype = 'number'">
         <xsl:value-of select="$argname"/>  
      </xsl:if>
      <xsl:if test="$argtype = 'string'">
         <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
         <xsl:value-of select="$argname"/>  
         <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
      </xsl:if>
      <xsl:if test="$argtype = 'vivtest'">
         <xsl:value-of select="$argname"/>  
      </xsl:if>
      <xsl:if test="$argtype = 'test'">
         <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
         <xsl:value-of select="$argname"/>  
         <xsl:text disable-output-escaping="yes"><![CDATA[']]></xsl:text>
      </xsl:if>
   </xsl:template>
   <!--   ###################################################################  -->

   <!--   ###################################################################  -->
   <xsl:template name="functionLine">
      <!--  =======================   -->
      <!--  This template generates a line of xsl that looks like:  -->
      <!--     <xsl:variable name="varname" select="funcname(arg1, arg2, ...)"/>  -->
      <!--  Example:  -->
      <!--     <xsl:variable name="resval" select="viv:if-else(true(), 'TRUE', 'FALSE')"/>  -->
      <!--  =======================   -->

      <!--  =======================   -->
      <!--  Initialize the template.   Get the number of arguments  -->
      <!--  and the trailer for the xsl line that is being generated -->
      <!--  =======================   -->
      <xsl:variable name="argcnt" select="count(argument)"/>
      <xsl:variable name="rear" select="string(')&quot;/')"/>

      <!--  =======================   -->
      <!--  Set up the first part of the xsl line, up the the name of  -->
      <!--  the function and the opening "("  -->
      <!--  =======================   -->
      <xsl:call-template name="functionPart">
         <xsl:with-param name="varname" select="string('resval')"/>
         <xsl:with-param name="varvalue" select="normalize-space(funcname)"/>
      </xsl:call-template>

      <xsl:for-each select="argument">
         <!--  =======================   -->
         <!--  For each function argument, output the value taking into account  -->
         <!--  type of value it is (function, variable, number, string, etc)  -->
         <!--  =======================   -->
         <xsl:call-template name="processArg">
            <xsl:with-param name="argname" select="normalize-space(value)"/>
            <xsl:with-param name="argtype" select="normalize-space(type)"/>
         </xsl:call-template>
         <!--  =======================   -->
         <!--  If this is not the last argument, put in a ","  -->
         <!--  argument seperator  -->
         <!--  =======================   -->
         <xsl:if test="position() &lt; $argcnt">
            <xsl:text disable-output-escaping="yes"><![CDATA[,]]></xsl:text>
         </xsl:if>
         <!--  =======================   -->
         <!--  If this is the last argument, put in a ")"  -->
         <!--  function argument list termination  -->
         <!--  =======================   -->
         <xsl:if test="position() >= $argcnt">
            <xsl:value-of select="$rear"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[>]]>
            </xsl:text>
         </xsl:if>
      </xsl:for-each>

   </xsl:template>
   <!--   ###################################################################  -->

   <!--   ###################################################################  -->
   <xsl:template match="/">
            <xsl:variable name="junk" select="testset/test" as="element()+"/>
            <xsl:for-each select="$junk">

                  <xsl:call-template name="fTemplateLev1A"/>

                  <!--  =======================   -->
                  <!--  Generate the variable assignment line for each named variable  -->
                  <!--  =======================   -->
                  <xsl:text disable-output-escaping="yes"><![CDATA[
                     <!--   Begin generated code -->
                  ]]></xsl:text>
                  <xsl:for-each select="variable">
                     <xsl:call-template name="variablelinecon">
                        <xsl:with-param name="varname" select="normalize-space(name)"/>
                        <xsl:with-param name="varvalue" select="normalize-space(value)"/>
                        <xsl:with-param name="vartype" select="normalize-space(type)"/>
                     </xsl:call-template>
                  </xsl:for-each>
                  <xsl:text disable-output-escaping="yes"><![CDATA[
                     <!--   End generated code -->

                  ]]></xsl:text>

                  <!--  =======================   -->
                  <!--  Results are the same as variables, but the variable name  -->
                  <!--  is always "expected"  -->
                  <!--  =======================   -->
                  <xsl:text disable-output-escaping="yes"><![CDATA[
                     <!--   Begin generated code -->
                  ]]></xsl:text>
                  <xsl:for-each select="result">
                     <xsl:call-template name="variablelinecon">
                        <xsl:with-param name="varname" select="string('expected')"/>
                        <xsl:with-param name="varvalue" select="normalize-space(value)"/>
                        <xsl:with-param name="vartype" select="normalize-space(type)"/>
                     </xsl:call-template>
                  </xsl:for-each>
                  <xsl:text disable-output-escaping="yes"><![CDATA[
                     <!--   End generated code -->

                  ]]></xsl:text>

                  <xsl:call-template name="fTemplateLev2A"/>

                  <xsl:text disable-output-escaping="yes"><![CDATA[
                     <!--   Begin generated code -->
                  ]]></xsl:text>
                  <xsl:call-template name="functionLine"/>
                  <xsl:text disable-output-escaping="yes"><![CDATA[
                     <!--   End generated code -->

                  ]]></xsl:text>

                  <xsl:call-template name="fTemplateLev3A"/>


                  <xsl:call-template name="fTemplateLev4A"/>

            </xsl:for-each>
   </xsl:template>
   <!--   ###################################################################  -->

</xsl:stylesheet>
