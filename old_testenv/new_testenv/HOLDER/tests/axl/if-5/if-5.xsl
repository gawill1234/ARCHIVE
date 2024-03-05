<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-5" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if condition test, simple regex not-match.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="vabc999" />

  <if test="viv:test($v, 'v.[0-9]+', 'regex')">
    <print>
       if-5:  TEST FAILED
    </print>
  </if>
  <if test="viv:test($v, 'v..q[0-9]+', 'regex')">
    <print>
       if-5:  TEST FAILED
    </print>
  </if>
  <if test="not(viv:test($v, 'v[a-z].[0-9]+', 'regex'))">
    <print>
       if-5:  TEST PASSED
    </print>
  </if>
  <if test="viv:test($v, 'v[a-z].999', 'regex')">
    <print>
       if-5:  TEST FAILED
    </print>
  </if>

</application>

</vce>