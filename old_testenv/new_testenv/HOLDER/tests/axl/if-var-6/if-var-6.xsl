<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-var-6" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if-var condition test, simple regex not-match using force-attribute.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="vabc999" />

  <if-var name="v">
    <forced-attribute name="match" value="v.[0-9]+"/>
    <forced-attribute name="match-type" value="regex"/>
    <print>
       if-var-6:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v">
    <forced-attribute name="match" value="v..q[0-9]+"/>
    <forced-attribute name="match-type" value="regex"/>
    <print>
       if-var-6:  TEST FAILED
    </print>
  </if-var>
  <if-var name="v">
    <forced-attribute name="not-match" value="v[a-z].[0-9]+"/>
    <forced-attribute name="match-type" value="regex"/>
    <print>
       if-var-6:  TEST PASSED
    </print>
  </if-var>
  <if-var name="v">
    <forced-attribute name="match" value="v[a-z].999"/>
    <forced-attribute name="match-type" value="regex"/>
    <print>
       if-var-6:  TEST FAILED
    </print>
  </if-var>

</application>

</vce>
