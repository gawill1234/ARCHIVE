<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-1" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if condition test.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="v" />

  <if test="$v = 'v3'">
    <print>
       if-1:  TEST FAILED
    </print>
  </if>
  <if test="$v = 'v2'">
    <print>
       if-1:  TEST FAILED
    </print>
  </if>
  <if test="$v = 'v'">
    <print>
       if-1:  TEST PASSED
    </print>
  </if>
  <if test="$v = 'vnot'">
    <print>
       if-1:  TEST FAILED
    </print>
  </if>

</application>

</vce>
