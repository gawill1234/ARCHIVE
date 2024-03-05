<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="choose-1" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html


]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="v" />

   <choose>
     <when-var name="v" match="v1" >
       <print>
          choose-1:  TEST FAILED
       </print>
     </when-var>
     <when-var name="v" match="v2">
       <print>
          choose-1:  TEST FAILED
       </print>
     </when-var>
     <when-var name="v" match="v">
       <print>
          choose-1:  TEST PASSED
       </print>
     </when-var>
     <otherwise>
       <print>
          choose-1:  TEST FAILED
       </print>
     </otherwise>
   </choose>

</application>

</vce>
