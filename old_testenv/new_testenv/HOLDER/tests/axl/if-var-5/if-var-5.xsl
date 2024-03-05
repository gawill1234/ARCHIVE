<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-var-5" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if-var condition test, simple regex not-match.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="vabc999" />

  <if-var name="v" match="v.[0-9]+" match-type="regex">
    <print>
       if-var-5:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v" match="v..q[0-9]+" match-type="regex">
    <print>
       if-var-5:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v" not-match="v[a-z].[0-9]+" match-type="regex">
    <print>
       if-var-5:  TEST PASSED
    </print>
  </if-var>
  <if-var name="v" match="v[a-z].999" match-type="regex">
    <print>
       if-var-5:  TEST FAILED
    </print>
  </if-var>

</application>

</vce>
