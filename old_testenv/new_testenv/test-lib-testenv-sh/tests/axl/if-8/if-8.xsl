<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-8" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if condition test. Integer value test.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="99" />

  <if test="$v = 1">
    <print>
       if-8:  TEST FAILED
    </print>
  </if>
  <if test="$v = 2">
    <print>
       if-8:  TEST FAILED
    </print>
  </if>
  <if test="$v = 99">
    <print>
       if-8:  TEST PASSED
    </print>
  </if>
  <if test="$v = 3">
    <print>
       if-8:  TEST FAILED
    </print>
  </if>

</application>

</vce>
