<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-11" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if condition test. Floating point value test.  greater than test.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="98.6" />

  <if test="$v > 98.6">
    <print>
       if-11:  TEST FAILED
    </print>
  </if>
  <if test="$v > 98.60">
    <print>
       if-11:  TEST FAILED
    </print>
  </if>
  <if test="$v > 98.59">
    <print>
       if-11:  TEST PASSED
    </print>
  </if>
  <if test="$v > 98.6000">
    <print>
       if-11:  TEST FAILED
    </print>
  </if>

</application>

</vce>
