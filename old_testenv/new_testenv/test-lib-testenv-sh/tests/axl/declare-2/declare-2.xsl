<application name="declare-2" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<expand-macro name="query-meta-cgi-parameters" />

<declare name="myx" type="string" initial-value="{normalize-space(viv:value-of('varname','param'))}"/>

<print><![CDATA[Content-Type:text/html

]]></print>

<print>
   <choose>
      <when-var name="myx" match="dirtydingusmcgee">
         <parse encode="encode">
            <parser type="html-xsl"><![CDATA[
               <xsl:template match="/">
                  <xsl:choose>
                     <xsl:when test="$myx = string('dirtydingusmcgee')">
                        declare-2:  TEST PASSED
                     </xsl:when>
                     <xsl:otherwise>
                        declare-2:  TEST FAILED
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:template>
            ]]></parser>
         </parse>
      </when-var>
      <otherwise>
            myx value:  <value-of-var name="myx"/><br/>
            declare-2:  TEST FAILED
      </otherwise>
   </choose>
</print>
</application>
