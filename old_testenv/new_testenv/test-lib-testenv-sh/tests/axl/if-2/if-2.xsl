<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-2" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

forced-attribute in a failed if condition should still be executed.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="v" />

  <if test="$v = 'v3'">
    <print>
       if-2:  TEST FAILED
    </print>
  </if>
  <if test="$v = 'v2'">
    <print>
       if-2:  TEST FAILED
    </print>
  </if>
  <if test="$v = 'v9'">
    <forced-attribute name="match" value="v1">
       <print>
          if-2:  TEST PASSED
       </print>
    </forced-attribute>
  </if>
  <if test="$v = 'vnot'">
    <print>
       if-2:  TEST FAILED
    </print>
  </if>

</application>

</vce>
