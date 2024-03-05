<application name="sss-1" modified-by="williams@vivisimo" modified="1209571541">

  <declare name="mynode" type="nodeset" />
  <set-var name="mynode">
     <process-xsl><![CDATA[
        <xsl:copy-of select="viv:search-service-status()"/>
     ]]></process-xsl>
  </set-var>

  <print><![CDATA[content-type:text/html


]]></print>

   <print>
      <copy-of select="$mynode"/>
   </print>

   <fetch timeout="1000" finish="finish" />

</application>
