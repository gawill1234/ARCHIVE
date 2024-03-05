<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-var-3" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if-var condition test, simple glob match.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="vabc999" />

  <if-var name="v" match="v1*">
    <print>
       if-var-3:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v" match="v2*">
    <print>
       if-var-3:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v" match="va*">
    <print>
       if-var-3:  TEST PASSED
    </print>
  </if-var>
  <if-var name="v" match="v9*">
    <print>
       if-var-3:  TEST FAILED
    </print>
  </if-var>

</application>

</vce>
