<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-var-1" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if-var condition test.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="v" />

  <if-var name="v" match="v1">
    <print>
       if-var-1:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v" match="v2">
    <print>
       if-var-1:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v" match="v">
    <print>
       if-var-1:  TEST PASSED
    </print>
  </if-var>
  <if-var name="v" match="v9">
    <print>
       if-var-1:  TEST FAILED
    </print>
  </if-var>

</application>

</vce>
