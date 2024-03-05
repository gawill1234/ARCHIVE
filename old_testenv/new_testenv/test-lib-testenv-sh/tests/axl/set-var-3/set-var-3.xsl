<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="set-var-3" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<declare name="myx" type="string"/>
<set-var name="myx"><![CDATA[dirtydingusmcgee]]></set-var>

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
                        set-var-3:  TEST PASSED
                     </xsl:when>
                     <xsl:otherwise>
                        set-var-3:  TEST FAILED
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:template>
            ]]></parser>
         </parse>
      </when-var>
      <otherwise>
            myx value:  <value-of-var name="myx"/><br/>
            set-var-3:  TEST FAILED
      </otherwise>
   </choose>
</print>
</application>

</vce>
