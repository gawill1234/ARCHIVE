<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
<vce version="4.0">

<application name="choose-2" modified-by="williams@vivisimo" max-elt-id="1" modified="1209571541">

<print><![CDATA[Content-Type:text/html

]]></print>

<declare name="v" type="string"/>
<set-var name="v" value="v" />

<choose>
  <when-var name="v" match="v1" >
    <print>
       choose-2:  TEST FAILED
    </print>
  </when-var>
  <when-var name="v" match="v2" />
  <when-var name="v" match="v3" />
  <otherwise>
    <print>
       choose-2:  TEST PASSED
    </print>
  </otherwise>
</choose>
</application>

</vce>
