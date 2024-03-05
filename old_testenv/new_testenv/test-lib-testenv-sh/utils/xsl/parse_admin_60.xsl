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

   <xsl:template name="getwcdictname">
      <xsl:variable name="wcdict-files"
        select="//vse-collection/vse-status[@which='live']/vse-index-status/term-expand-dicts-status/term-expand-dict-status"
      /> 
      <xsl:choose>
         <xsl:when test="count($wcdict-files) > 0">
            <xsl:value-of select="$wcdict-files/@filename"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>NOFILE</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindexfilecount">
      <xsl:variable name="index-files"
        select="//vse-collection/vse-status[@which='live']/vse-index-status/vse-index-file"
      /> 
      <xsl:choose>
         <xsl:when test="count($index-files) > 0">
            <xsl:value-of select="count($index-files)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text><![CDATA[0]]></xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindexedcontents">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@indexed-contents"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@indexed-contents"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindexeddocs">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@indexed-docs"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@indexed-docs"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindextime">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@indexing-time"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@indexing-time"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindexedurls">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@indexed-urls"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@indexed-urls"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawledbytes">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-bytes"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-bytes"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawlelapsed">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@elapsed"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@elapsed"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawloutputs">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-output"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-output"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="crawlerwaitidxreply">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-awaiting-index-reply"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-awaiting-index-reply"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="crawlerwaitidxinput">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-awaiting-index-input"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-awaiting-index-input"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawlinputs">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-input"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-input"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="crwltrdidxoutput">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:for-each select="$stagdata">
               <xsl:for-each select="//crawl-thread">
                  <xsl:variable name="idxmsgthrd" select="@name"/>
                  <xsl:variable name="idxmsgcnt" select="@state"/>
                  <xsl:if test="$idxmsgthrd = 'indexer output'">
                     <xsl:if test="$idxmsgcnt != 'idle'">
                        <xsl:value-of select="$idxmsgcnt"/>
                     </xsl:if>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:for-each select="$livedata">
               <xsl:for-each select="//crawl-thread">
                  <xsl:variable name="idxmsgthrd" select="@name"/>
                  <xsl:variable name="idxmsgcnt" select="@state"/>
                  <xsl:if test="$idxmsgthrd = 'indexer output'">
                     <xsl:if test="$idxmsgcnt != 'idle'">
                        <xsl:value-of select="$idxmsgcnt"/>
                     </xsl:if>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>None</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawldups">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-duplicates"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-duplicates"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawlpending">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-pending"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-pending"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcrawlerrors">
      <xsl:variable name="livedata"
       select="//vse-collection/vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-collection/vse-status[@which='staging']/crawler-status"/>
      <xsl:choose>
         <xsl:when test="count($stagdata) > 0">
            <xsl:value-of select="$stagdata/@n-errors"/>
         </xsl:when>
         <xsl:when test="count($livedata) > 0">
            <xsl:value-of select="$livedata/@n-errors"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="recuradder">
      <xsl:param name="nodes"/>
      <xsl:param name="result"/>
      <xsl:choose>
         <xsl:when test="not($nodes)">
            <xsl:value-of select="$result"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="value" select="$nodes[1]/@size"/>
            <xsl:call-template name="recuradder">
               <xsl:with-param name="nodes" select="$nodes[position() != 1]"/>
               <xsl:with-param name="result" select="$result + $value"/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindexsize">
      <xsl:variable name="status"
        select="//vse-collection/vse-status[@which='live']/vse-index-status"
      /> 
      <xsl:if test="count($status) != 1">
         <xsl:message terminate="yes">valid_index_docs:  Invalid number of live status nodes, there are <xsl:value-of select="count($status)"/> and I require exactly one.</xsl:message>
      </xsl:if>

      <xsl:variable name="index-files"
         select="$status/vse-index-file[@type='index']"
      /> 
      <xsl:choose>
         <xsl:when test="count($index-files) > 1">
            <xsl:call-template name="recuradder">
               <xsl:with-param name="nodes" select="$index-files"/>
               <xsl:with-param name="result" select="0"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:when test="$index-files/@size">
            <xsl:value-of select="$index-files/@size"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text><![CDATA[0]]></xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getvalidindex">
      <xsl:variable name="status"
        select="//vse-collection/vse-status[@which='live']/vse-index-status"
      /> 
      <xsl:if test="count($status) != 1">
         <xsl:message terminate="yes">valid_index_docs:  Invalid number of live status nodes, there are <xsl:value-of select="count($status)"/> and I require exactly one.</xsl:message>
      </xsl:if>

      <xsl:variable name="docs-data"
         select="$status/vse-index-file[@type='docs-data']"
      /> 

      <xsl:variable name="index-files"
         select="$status/vse-index-file[@type='index']"
      /> 
      <xsl:choose>
         <xsl:when test="$status/@n-docs">
            <xsl:value-of select="$status/@n-docs"/>
         </xsl:when>
         <xsl:when test="$docs-data">
            <xsl:value-of select="$docs-data/@n-docs"/>
         </xsl:when>
         <xsl:when test="count($index-files) > 1">
            <xsl:message terminate="yes">valid_index_docs : multiple index files with no docs-data file is not supposed to be possible.</xsl:message>
         </xsl:when>
         <xsl:when test="$index-files/@n-docs">
            <xsl:value-of select="$index-files/@n-docs"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text><![CDATA[0]]></xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="liveindexpath">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->

      <xsl:variable name="indexpath"
       select="//vse-collection/vse-run[@which='live']/vse-index/run/@path"/>

      <!--   ###########################################################  -->

      <xsl:choose>
         <xsl:when test="string($indexpath) != ''">
            <xsl:value-of select="$indexpath"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>crawl*</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <xsl:template name="anylivepid">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->

      <xsl:variable name="crawlerpid"
       select="//vse-collection/vse-run[@which='live']/crawler/run/@pid"/>

      <xsl:variable name="indexerpid"
       select="//vse-collection/vse-run[@which='live']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <xsl:choose>
         <xsl:when test="string($crawlerpid) != ''">
            <xsl:text>Crawler</xsl:text>
         </xsl:when>

         <xsl:when test="string($indexerpid) != ''">
            <xsl:text>Indexer</xsl:text>
         </xsl:when>

         <xsl:otherwise>
            <xsl:text>Nothing</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <xsl:template name="anystagingpid">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->

      <xsl:variable name="crawlerpid"
       select="//vse-collection/vse-run[@which='staging']/crawler/run/@pid"/>

      <xsl:variable name="indexerpid"
       select="//vse-collection/vse-run[@which='staging']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <xsl:choose>
         <xsl:when test="string($crawlerpid) != ''">
            <xsl:text>Crawler</xsl:text>
         </xsl:when>

         <xsl:when test="string($indexerpid) != ''">
            <xsl:text>Indexer</xsl:text>
         </xsl:when>

         <xsl:otherwise>
            <xsl:text>Nothing</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <xsl:template name="stagcrawlstatus">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->

      <xsl:variable name="crawlerpid"
       select="//vse-collection/vse-run[@which='staging']/crawler/run/@pid"/>

      <xsl:variable name="indexerpid"
       select="//vse-collection/vse-run[@which='staging']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a live node             -->

      <xsl:variable name="crawlerpidlv"
       select="//vse-collection/vse-run[@which='live']/crawler/run/@pid"/>

      <xsl:variable name="indexerpidlv"
       select="//vse-collection/vse-run[@which='live']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlidle"
       select="//vse-collection/vse-status[@which='staging']/crawler-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexidle"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@idle"/>

      <xsl:variable name="collsrvidle"
       select="//vse-collection/vse-status[@which='staging']/collection-service-status/@idle"/>

      <xsl:variable name="collsrvidlelv"
       select="//vse-collection/vse-status[@which='live']/collection-service-status/@idle"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlidlelv"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexidlelv"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@idle"/>
      <!--   ###########################################################  -->

       
      <xsl:choose>
         <!--   There is a crawler running  -->
         <xsl:when test="string($crawlerpid) != ''">
            <xsl:choose>
               <!--   There is a crawler running and idle -->
               <xsl:when test="string($crawlidle) = 'idle'">
                  <xsl:choose>
                     <xsl:when test="string($indexidle) = 'idle'">
                        <xsl:text>Crawler and indexer are idle.</xsl:text>
                     </xsl:when>
                     <xsl:when test="string($indexerpid) = ''">
                        <xsl:text>Crawler and indexer are idle.</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>Indexer running</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Crawler running</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!--   END OF There is a crawler running  -->
         <!--   There is no crawler running  -->
         <xsl:when test="string($crawlerpid) = ''">
            <xsl:choose>
               <xsl:when test="string($indexidle) = 'idle'">
                  <xsl:text>Crawler and indexer are idle.</xsl:text>
               </xsl:when>
               <xsl:when test="string($indexerpid) = ''">
                  <xsl:text>Crawler and indexer are idle.</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Indexer running</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!--   END OF There is no crawler running  -->
         <xsl:otherwise>
            <xsl:text>Crawler running</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <!--   ##############################################################  -->
   <xsl:template name="livecrawlstatus">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->

      <xsl:variable name="crawlerpid"
       select="//vse-collection/vse-run[@which='staging']/crawler/run/@pid"/>

      <xsl:variable name="indexerpid"
       select="//vse-collection/vse-run[@which='staging']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a live node             -->

      <xsl:variable name="crawlerpidlv"
       select="//vse-collection/vse-run[@which='live']/crawler/run/@pid"/>

      <xsl:variable name="indexerpidlv"
       select="//vse-collection/vse-run[@which='live']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlidle"
       select="//vse-collection/vse-status[@which='staging']/crawler-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexidle"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@idle"/>

      <xsl:variable name="collsrvidle"
       select="//vse-collection/vse-status[@which='staging']/collection-service-status/@idle"/>

      <xsl:variable name="collsrvidlelv"
       select="//vse-collection/vse-status[@which='live']/collection-service-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlidlelv"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexidlelv"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@idle"/>
      <!--   ###########################################################  -->

       
      <xsl:choose>
         <!--   There is a crawler running  -->
         <xsl:when test="string($crawlerpidlv) != ''">
            <xsl:choose>
               <!--   There is a crawler running and idle -->
               <xsl:when test="string($crawlidlelv) = 'idle'">
                  <xsl:choose>
                     <xsl:when test="string($indexidlelv) = 'idle'">
                        <xsl:text>Crawler and indexer are idle.</xsl:text>
                     </xsl:when>
                     <xsl:when test="string($indexerpidlv) = ''">
                        <xsl:text>Crawler and indexer are idle.</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text>Indexer running</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Crawler running</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!--   END OF There is a crawler running  -->
         <!--   There is no crawler running  -->
         <xsl:when test="string($crawlerpidlv) = ''">
            <xsl:choose>
               <xsl:when test="string($indexidlelv) = 'idle'">
                  <xsl:text>Crawler and indexer are idle.</xsl:text>
               </xsl:when>
               <xsl:when test="string($indexerpidlv) = ''">
                  <xsl:text>Crawler and indexer are idle.</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>Indexer running</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <!--   END OF There is no crawler running  -->
         <xsl:otherwise>
            <xsl:text>Crawler running</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <!--   ##############################################################  -->
   <xsl:template name="livecrawlstatusnopid">

      <xsl:variable name="stagingstat"
       select="//vse-collection/vse-status[@which='staging']/@token"/>

      <xsl:variable name="livestat"
       select="//vse-collection/vse-status[@which='live']/@token"/>

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlexists"
       select="//vse-collection/vse-status[@which='staging']/crawler-status/@time"/>

      <xsl:variable name="crawlexistslv"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@time"/>
      <xsl:variable name="crawlidle"
       select="//vse-collection/vse-status[@which='staging']/crawler-status/@idle"/>

      <xsl:variable name="crawlidlelv"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@idle"/>

      <xsl:variable name="crawlstopped"
       select="//vse-collection/vse-status[@which='staging']/crawler-status/@final"/>

      <xsl:variable name="crawlstoppedlv"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@final"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexexists"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@running-time"/>
      <xsl:variable name="indexexistslv"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@running-time"/>

      <xsl:variable name="indexidle"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@idle"/>

      <xsl:variable name="indexidlelv"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@idle"/>

      <xsl:variable name="indexstopped"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@stopped-at"/>

      <xsl:variable name="indexstoppedlv"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@stopped-at"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="collsrvexists"
       select="//vse-collection/vse-status[@which='staging']/collection-service-status/@running-time"/>

      <xsl:variable name="collsrvidle"
       select="//vse-collection/vse-status[@which='staging']/collection-service-status/@idle"/>

      <xsl:variable name="collsrvexistslv"
       select="//vse-collection/vse-status[@which='live']/collection-service-status/@running-time"/>

      <xsl:variable name="collsrvidlelv"
       select="//vse-collection/vse-status[@which='live']/collection-service-status/@idle"/>
      <!--   ###########################################################  -->
       
      <xsl:choose>
         <xsl:when test="$indexexistslv != '' and
                         string($indexidlelv) != 'idle' and
                         string($indexstoppedlv) = ''">
               <xsl:text>Indexer running</xsl:text>
         </xsl:when>
         <xsl:when test="$crawlexistslv != '' and
                         string($crawlidlelv) != 'idle' and
                         string($crawlstoppedlv) = ''">
               <xsl:text>Crawler running</xsl:text>
         </xsl:when>
         <xsl:when test="$collsrvexistslv != '' and
                         string($collsrvidlelv) != 'idle'">
               <xsl:text>Crawler running</xsl:text>
         </xsl:when>
         <xsl:when test="$indexexists != '' and
                         string($indexidle) != 'idle' and
                         string($indexstopped) = ''">
               <xsl:text>Indexer running</xsl:text>
         </xsl:when>
         <xsl:when test="$crawlexists != '' and
                         string($crawlidle) != 'idle' and
                         string($crawlstopped) = ''">
               <xsl:text>Crawler running</xsl:text>
         </xsl:when>
         <xsl:when test="$collsrvexists != '' and
                         string($collsrvidle) != 'idle'">
               <xsl:text>Crawler running</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Crawler and indexer are idle.</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

   </xsl:template>

   <xsl:template name="crawlstatus">

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a staging node             -->

      <xsl:variable name="crawlerpid"
       select="//vse-collection/vse-run[@which='staging']/crawler/run/@pid"/>

      <xsl:variable name="indexerpid"
       select="//vse-collection/vse-run[@which='staging']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variable to determine if there is a live node             -->

      <xsl:variable name="crawlerpidlv"
       select="//vse-collection/vse-run[@which='live']/crawler/run/@pid"/>

      <xsl:variable name="indexerpidlv"
       select="//vse-collection/vse-run[@which='live']/vse-index/run/@pid"/>

      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlidle"
       select="//vse-collection/vse-status[@which='staging']/crawler-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexidle"
       select="//vse-collection/vse-status[@which='staging']/vse-index-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the crawl is complete in the live       -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="crawlidlelv"
       select="//vse-collection/vse-status[@which='live']/crawler-status/@idle"/>
      <!--   ###########################################################  -->

      <!--   ###########################################################  -->
      <!--   Variables to find if the indexer is running in the live      -->
      <!--   and staging nodes.                                           -->

      <xsl:variable name="indexidlelv"
       select="//vse-collection/vse-status[@which='live']/vse-index-status/@idle"/>
      <!--   ###########################################################  -->

       
      <xsl:choose>
         <xsl:when test="string($indexerpid) != ''">
            <xsl:call-template name="stagcrawlstatus"/>
         </xsl:when>
         <xsl:when test="string($crawlerpid) != ''">
            <xsl:call-template name="stagcrawlstatus"/>
         </xsl:when>
         <xsl:when test="string($indexerpidlv) != ''">
            <xsl:call-template name="livecrawlstatus"/>
         </xsl:when>
         <xsl:when test="string($crawlerpidlv) != ''">
            <xsl:call-template name="livecrawlstatus"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="livecrawlstatusnopid"/>
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
         <xsl:when test="$mynode = 'crawl-elapsed'">
            <xsl:call-template name="getcrawlelapsed"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawled-bytes'">
            <xsl:call-template name="getcrawledbytes"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-path'">
            <xsl:call-template name="liveindexpath"/>
         </xsl:when>
         <xsl:when test="$mynode = 'live-crawl-status'">
            <xsl:call-template name="livecrawlstatus"/>
         </xsl:when>
         <xsl:when test="$mynode = 'staging-crawl-status'">
            <xsl:call-template name="stagcrawlstatus"/>
         </xsl:when>
         <xsl:when test="$mynode = 'staging-run'">
            <xsl:call-template name="anystagingpid"/>
         </xsl:when>
         <xsl:when test="$mynode = 'live-run'">
            <xsl:call-template name="anylivepid"/>
         </xsl:when>
         <xsl:when test="$mynode = 'valid-index'">
            <xsl:call-template name="getvalidindex"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-dups'">
            <xsl:call-template name="getcrawldups"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-errors'">
            <xsl:call-template name="getcrawlerrors"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-outputs'">
            <xsl:call-template name="getcrawloutputs"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-idx-reply'">
            <xsl:call-template name="crawlerwaitidxreply"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-idx-input'">
            <xsl:call-template name="crawlerwaitidxinput"/>
         </xsl:when>
         <xsl:when test="$mynode = 'ct-idx-output-state'">
            <xsl:call-template name="crwltrdidxoutput"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-pending'">
            <xsl:call-template name="getcrawlpending"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-docs'">
            <xsl:call-template name="getindexeddocs"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-size'">
            <xsl:call-template name="getindexsize"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-time'">
            <xsl:call-template name="getindextime"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-contents'">
            <xsl:call-template name="getindexedcontents"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-file-count'">
            <xsl:call-template name="getindexfilecount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-urls'">
            <xsl:call-template name="getindexedurls"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-inputs'">
            <xsl:call-template name="getcrawlinputs"/>
         </xsl:when>
         <xsl:when test="$mynode = 'wcdict-name'">
            <xsl:call-template name="getwcdictname"/>
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
         <xsl:when test="$mynode = 'version'">
            <xsl:for-each select="//vse-collection/vse-status[@which='live']">
               <xsl:value-of select="@version"/>
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
