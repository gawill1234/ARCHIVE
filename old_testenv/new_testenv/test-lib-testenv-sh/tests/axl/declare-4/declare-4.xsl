<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="declare-4" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<declare name="myxnode" type="nodeset" />
<set-var name="myxnode">
  <dirty><dingus><mcgee>dirtydingusmcgee</mcgee></dingus></dirty>
</set-var>

<declare name="myx" type="string" />
<set-var name="myx">
   <value-of select="$myxnode//dingus/mcgee"/>
</set-var>

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
                        declare-4:  TEST PASSED
                     </xsl:when>
                     <xsl:otherwise>
                        declare-4:  TEST FAILED
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:template>
            ]]></parser>
         </parse>
      </when-var>
      <otherwise>
            myx value:  <value-of-var name="myx"/><br/>
            declare-4:  TEST FAILED
      </otherwise>
   </choose>
</print>
</application>

</vce>
