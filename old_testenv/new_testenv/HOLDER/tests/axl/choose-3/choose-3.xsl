<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="choose-3" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html


]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="v" />

   <choose>
     <when test="contains($v, 'w')">
       <print>
          choose-3:  TEST FAILED
       </print>
     </when>
     <when-var name="v" not-match="v" />
     <when test="$v = 'v'">
       <print>
          choose-3:  TEST PASSED
       </print>
     </when>
   </choose>

</application>

</vce>
