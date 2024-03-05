<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="if-14" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">
  <print><![CDATA[content-type:text/html

Basic if condition test. Floating point value test.  equality test.
]]></print>

   <declare name="v" type="string"/>
   <set-var name="v" value="98.6" />

  <if test="$v = 98.6">
    <print>
       if-14:  TEST PASSED
    </print>
  </if>
  <if test="$v = 98.60">
    <print>
       if-14:  TEST PASSED
    </print>
  </if>
  <if test="$v = 98.599">
    <print>
       if-14:  TEST FAILED
    </print>
  </if>
  <if test="$v = 98.601">
    <print>
       if-14:  TEST FAILED
    </print>
  </if>
  <if test="$v = 98.600">
    <print>
       if-14:  TEST PASSED
    </print>
  </if>

</application>

</vce>
