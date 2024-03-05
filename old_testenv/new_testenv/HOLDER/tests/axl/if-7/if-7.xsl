<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-7" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if condition test, viv:match() simple glob match.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="vabc999" />

  <if test="viv:test($v, 'v1*')">
    <print>
       if-7:  TEST FAILED
    </print>
  </if>
  <if test="viv:test($v, 'v2*')">
    <print>
       if-7:  TEST FAILED
    </print>
  </if>
  <if test="viv:test($v, 'va*')">
    <print>
       if-7:  TEST PASSED
    </print>
  </if>
  <if test="viv:test($v, 'v9*')">
    <print>
       if-7:  TEST FAILED
    </print>
  </if>

</application>

</vce>
