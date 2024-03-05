<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="fileStat-1" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<declare name="myx" type="nodeset"/>
<set-var name="myx">
   <process-xsl><![CDATA[
      <xsl:copy-of select="file:stat('../../data/repository.xml')"/>
   ]]></process-xsl>
</set-var>

<declare name="myx2"/>
<set-var name="myx2">
   <value-of select="$myx/size"/>
</set-var>

<print><![CDATA[Content-Type:text/html

]]></print>
<print>
   <choose>
      <when-var name="myx2" match="796">
            fileStat-1:  TEST PASSED
      </when-var>
      <otherwise>
            size:  <value-of-var name="myx2"/><br/>
            fileStat-1:  TEST FAILED
      </otherwise>
   </choose>
</print>
</application>

</vce>
