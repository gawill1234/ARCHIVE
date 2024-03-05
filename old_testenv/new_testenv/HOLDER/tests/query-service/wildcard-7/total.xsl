<?xml version="1.0" ?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:str="http://exslt.org/strings"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:math="http://exslt.org/math"
  xmlns:func="http://exslt.org/functions"
  xmlns:exsl="http://exslt.org/common"
  xmlns:set="http://exslt.org/sets"
  extension-element-prefixes="str date math func exsl set"
>
<xsl:output method="text" indent="no" encoding="UTF-8"
/>

<xsl:template match="/">
  <xsl:value-of select="number(//added-source/@total-results-with-duplicates)"/>
</xsl:template>

</xsl:stylesheet>
