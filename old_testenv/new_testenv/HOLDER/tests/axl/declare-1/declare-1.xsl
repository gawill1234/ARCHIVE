<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="declare-1" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<declare name="myx" type="string" initial-value="dirtydingusmcgee"/>

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
                        declare-1:  TEST PASSED
                     </xsl:when>
                     <xsl:otherwise>
                        declare-1:  TEST FAILED
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:template>
            ]]></parser>
         </parse>
      </when-var>
      <otherwise>
            myx value:  <value-of-var name="myx"/><br/>
            declare-1:  TEST FAILED
      </otherwise>
   </choose>
</print>
</application>

</vce>
