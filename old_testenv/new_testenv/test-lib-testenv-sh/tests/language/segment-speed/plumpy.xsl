<?xml version='1.0'?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:msxsl="urn:schemas-microsoft-com:xslt"
    xmlns: myJavaScript ="urn:internal:my-javascript">
    <msxsl:script language="JScript" implements-prefix="myJavaScript">
    <![CDATA[
        function gawGetMSecs()
        {
        var currentTime = new Date();
        var msecs = currentTime.getTime();
        return(msecs);
        }
    ]]>
    </msxsl:script>

<xsl:template match="/">
    <xsl:value-of select="myJavaScript:GetCurrentDateTime()"/>
</xsl:template>

</xsl:stylesheet>
