<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<!--   ###########################################################  -->
<!--   Make the output be raw text.  This way we don't get that     -->
<!--   Irritating <?xml version="1.0"?> line as the first line      -->
<!--   of output.                                                   -->
<xsl:output method="text"/>
<!--   ###########################################################  -->

<xsl:param name="mynode" as="xs:string"/>
<xsl:param name="mytrib" as="xs:string"/>

   <!--   ##############################################################  -->
   <xsl:template name="crawlstatus">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->
      <xsl:variable name="staging"
       select="//vse-collection/vse-status[@which='staging']"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->
      <xsl:variable name="scrawlcomp"
       select="//vse-status[@which='staging']/crawler-status/@complete"/>
      <xsl:variable name="lcrawlcomp"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@complete"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->
      <xsl:variable name="sindexrun"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@running"/>
      <xsl:variable name="lindexrun"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@running"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is done in the live         -->
      <!--   and staging nodes.                                           -->
      <xsl:variable name="sindexend"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@end-time"/>
      <xsl:variable name="lindexend"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@end-time"/>
      <!--   ###########################################################  -->

      <xsl:choose>
         <xsl:when test="count($staging) > 0">
            <xsl:choose>
               <xsl:when test="string($scrawlcomp) = 'complete'">
                  <xsl:if test="string($sindexrun) = 'running'">
                     <xsl:text>Indexer running</xsl:text>
                  </xsl:if>
                  <xsl:if test="string($sindexend) != ''">
                     <xsl:text>Crawler and indexer are idle (staging)</xsl:text>
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Crawler running</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="string($lcrawlcomp) = 'complete'">
                  <xsl:if test="string($lindexrun) = 'running'">
                     <xsl:text>Indexer running</xsl:text>
                  </xsl:if>
                  <xsl:if test="string($lindexend) != ''">
                     <xsl:text>Crawler and indexer are idle (live)</xsl:text>
                  </xsl:if>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Crawler running</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--   ##############################################################  -->
   <xsl:template match="/">
      <xsl:choose>
         <!--   ##############################################   -->
         <!--   Get the current crawl status for a given         -->
         <!--   collection.                                      -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawl-status'">
            <xsl:call-template name="crawlstatus"/>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawler-status-live'">
            <xsl:for-each select="//vse-collection/vse-status[@which='live']/crawler-status">
               <xsl:value-of select="(@*[local-name()=$mytrib])"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawler-status'">
            <xsl:for-each select="//vse-collection/vse-status[@which='staging']/crawler-status">
               <xsl:value-of select="(@*[local-name()=$mytrib])"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawler-status-staging'">
            <xsl:for-each select="//vse-collection/vse-status[@which='staging']/crawler-status">
               <xsl:value-of select="(@*[local-name()=$mytrib])"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'indexer-status'">
            <xsl:for-each select="//vse-collection/vse-status[@which='live']/vse-index-status">
               <xsl:value-of select="(@*[local-name()=$mytrib])"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawler-run'">
            <xsl:for-each select="//vse-collection/vse-run/crawler">
               <xsl:value-of select="(@*[local-name()=$mytrib])"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'indexer-run'">
            <xsl:for-each select="//vse-collection/vse-run/vse-index">
               <xsl:value-of select="(@*[local-name()=$mytrib])"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   Get the current crawler pid for a given          -->
         <!--   collection.                                      -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawler-pid'">
            <xsl:for-each select="//vse-collection/vse-run/crawler/run">
               <xsl:value-of select="@pid"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   Get the current indexer pid for a given          -->
         <!--   collection.                                      -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'indexer-pid'">
            <xsl:for-each select="//vse-collection/vse-run/vse-index/run">
               <xsl:value-of select="@pid"/>
            </xsl:for-each>
         </xsl:when>
         <!--   ##############################################   -->
         <!--   Get the current crawl urls for a given           -->
         <!--   collection.  Seperate each url with a space.     -->
         <!--   ##############################################   -->
         <xsl:when test="$mynode = 'crawl-urls'">
            <xsl:for-each select="//vse-collection/vse-config/crawler/crawl-urls/crawl-url">
               <xsl:value-of select="@url"/>
               <xsl:text disable-output-escaping="yes"> </xsl:text>
            </xsl:for-each>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
