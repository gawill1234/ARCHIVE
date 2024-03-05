<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="set-var-4" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<declare name="myx" type="boolean"/>
<set-var name="myx">
   <process-xsl><![CDATA[
      <xsl:value-of select="true()"/>
   ]]></process-xsl>
</set-var>

<print><![CDATA[Content-Type:text/html

]]></print>

<print>
   <choose>
      <when-var name="myx" match="true">
         <parse encode="encode">
            <parser type="html-xsl"><![CDATA[
               <xsl:template match="/">
                  <xsl:choose>
                     <xsl:when test="$myx = true()">
                        set-var-4:  TEST PASSED
                     </xsl:when>
                     <xsl:otherwise>
                        myx value(UP):  <value-of-var name="myx"/><br/>
                        set-var-4:  TEST FAILED
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:template>
            ]]></parser>
         </parse>
      </when-var>
      <otherwise>
            myx value(DOWN):  <value-of-var name="myx"/><br/>
            set-var-4:  TEST FAILED
      </otherwise>
   </choose>
</print>
</application>

</vce>
