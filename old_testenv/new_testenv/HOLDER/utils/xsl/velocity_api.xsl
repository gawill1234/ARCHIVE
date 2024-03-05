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
<xsl:param name="myname" as="xs:string"/>

   <xsl:template name="jidlist">
      <xsl:for-each select="//source">
         <xsl:value-of select="@job-id"/>
         <xsl:text>&#xa;</xsl:text>
      </xsl:for-each>
   </xsl:template>
   
   <xsl:template name="getqueryclustertree">
      <xsl:if test="count(//tree/node/node) > 0">
         <xsl:for-each select="//tree/node/node">
            <xsl:variable name="mynodetype" select="@type"/>
            <xsl:if test="$mynodetype != 'more'">
               <xsl:value-of select="."/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getqueryclustertree2">
      <xsl:if test="count(//tree/node/node) > 0">
         <xsl:for-each select="//tree/node/node">
            <xsl:value-of select="."/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getqueryclustercount">
      <xsl:choose>
         <xsl:when test="count(//tree/node/node[@type='close']) > 0">
            <xsl:value-of select="count(//tree/node/node[@type='close'])"/>
         </xsl:when>
         <xsl:when test="count(//tree/node/node[@type='document']) > 0">
            <xsl:value-of select="count(//tree/node/node[@type='document'])"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getqueryresultfile">
      <xsl:choose>
         <xsl:when test="count(//query-results/@file) > 0">
            <xsl:value-of select="//query-results/@file"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>None</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getqueryurlcount">
      <xsl:choose>
         <xsl:when test="count(//list/document) > 0">
            <xsl:value-of select="count(//list/document)"/>
         </xsl:when>
         <xsl:when test="count(//tree/node/document) > 0">
            <xsl:value-of select="count(//tree/node/document)"/>
         </xsl:when>
         <xsl:when test="count(//document) > 0">
            <xsl:value-of select="count(//document)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcacheurlcount">
      <xsl:choose>
         <xsl:when test="count(//document/cache) > 0">
            <xsl:value-of select="count(//document/cache/@url)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcachedatacount">
      <xsl:choose>
         <xsl:when test="count(//document/cache/crawl-data/text) > 0">
            <xsl:value-of select="count(//document/cache//crawl-data/text)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getitemcount">
      <xsl:choose>
         <xsl:when test="count(//document/content[@name=$mytrib]) > 0">
            <xsl:value-of select="count(//document/content[@name=$mytrib])"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getdocattrcount">
      <xsl:choose>
         <xsl:when test="count(//document[@*[local-name()=$mytrib]]) > 0">
            <xsl:value-of select="count(//document[@*[local-name()=$mytrib]])"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getdocattrvalues">
      <xsl:choose>
         <xsl:when test="count(//document[@*[local-name()=$mytrib]]) > 0">
            <xsl:for-each select="//document">
               <xsl:value-of select="(@*[local-name()=$mytrib])[position()=1]"/>
               <xsl:text> </xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text> </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcontentattrvalues">
      <xsl:choose>
         <xsl:when test="count(//document/content[@*[local-name()=$mytrib]]) > 0">
            <xsl:for-each select="//document/content">
               <xsl:value-of select="(@*[local-name()=$mytrib])[position()=1]"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcbscollectionattrvaluesbyname">
      <xsl:choose>
         <xsl:when
              test="count(//collection/@*[local-name()=$mytrib]) > 0">
            <xsl:for-each select="//collection">
               <xsl:variable name="thisname" select="@name"/>
               <xsl:if test="$thisname = $myname">
                  <xsl:variable name="thisthing"
                       select="(@*[local-name()=$mytrib])[position()=1]"/>
                  <xsl:if test="$thisthing != ''">
                     <xsl:value-of select="$thisthing"/>
                     <xsl:text>&#xa;</xsl:text>
                  </xsl:if>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcbscollectionnames">
      <xsl:if test="count(//collection) > 0">
         <xsl:for-each select="//collection">
            <xsl:value-of select="@name"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getcbcollectionservicestatus">
      <xsl:choose>
         <xsl:when test="count(//collection-broker-collection-status) > 0">
            <xsl:choose>
               <xsl:when test="$mytrib = 'crawler'">
                  <xsl:text>crawler</xsl:text>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:value-of select="//collection-broker-collection-status/crawler-status/@online"/>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:choose>
                     <xsl:when test="//collection-broker-collection-status/crawler-status/@pid = ''">
                        <xsl:text>0</xsl:text>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//collection-broker-collection-status/crawler-status/@pid"/>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$mytrib = 'indexer'">
                  <xsl:text>indexer</xsl:text>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:value-of select="//collection-broker-collection-status/indexer-status/@online"/>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:choose>
                     <xsl:when test="//collection-broker-collection-status/indexer-status/@pid = ''">
                        <xsl:text>0</xsl:text>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//collection-broker-collection-status/indexer-status/@pid"/>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>crawler</xsl:text>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:value-of select="//collection-broker-collection-status/crawler-status/@online"/>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:choose>
                     <xsl:when test="//collection-broker-collection-status/crawler-status/@pid = ''">
                        <xsl:text>0</xsl:text>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//collection-broker-collection-status/crawler-status/@pid"/>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
                  <xsl:text>indexer</xsl:text>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:value-of select="//collection-broker-collection-status/indexer-status/@online"/>
                  <xsl:text>&#xa;</xsl:text>
                  <xsl:choose>
                     <xsl:when test="//collection-broker-collection-status/indexer-status/@pid = ''">
                        <xsl:text>0</xsl:text>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="//collection-broker-collection-status/indexer-status/@pid"/>
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcontentattrvaluesbyname">
      <xsl:choose>
         <xsl:when
              test="count(//document/content/@*[local-name()=$mytrib]) > 0">
            <xsl:for-each select="//document/content">
               <xsl:variable name="thisname" select="@name"/>
               <xsl:if test="$thisname = $myname">
                  <xsl:variable name="thisthing"
                       select="(@*[local-name()=$mytrib])[position()=1]"/>
                  <xsl:if test="$thisthing != ''">
                     <xsl:value-of select="$thisthing"/>
                     <xsl:text>&#xa;</xsl:text>
                  </xsl:if>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getcontentvalues">
      <xsl:choose>
         <xsl:when test="count(//document/content[@name=$mytrib]) > 0">
            <xsl:for-each select="//document/content[@name=$mytrib]">
               <xsl:value-of select="."/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getquerypagecount">
      <xsl:choose>
         <xsl:when test="count(//added-source/parse) > 0">
            <xsl:value-of select="count(//added-source/parse)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getqueryquery">
      <xsl:if test="count(//query//term) > 0">
         <xsl:for-each select="//query//term">
            <xsl:value-of select="@str"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getqueryoperator">
      <xsl:if test="count(//query//operator) > 0">
         <xsl:for-each select="//query//operator">
            <xsl:value-of select="@logic"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="holderofoldgetquerytotalresults">
      <xsl:choose>
         <xsl:when test="count(//added-source) > 0">
            <xsl:for-each select="//added-source">
               <xsl:variable name="qstat" select="@status"/>
               <xsl:choose>
                  <xsl:when test="$qstat = 'queried'">
                     <xsl:value-of select="@total-results-with-duplicates"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>0</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getquerytotalresults">
      <xsl:variable name="ascount" select="count(//added-source)"/>
      <xsl:choose>
         <xsl:when test="$ascount > 0">
            <xsl:for-each select="//added-source">
               <xsl:variable name="qstat" select="@status"/>
               <xsl:choose>
                  <xsl:when test="$qstat = 'queried'">
                     <xsl:value-of select="@total-results-with-duplicates"/>
                     <xsl:if test="$ascount > 1">
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>0</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="holderofgetqueryretrieved">
      <xsl:choose>
         <xsl:when test="count(//added-source) > 0">
            <xsl:for-each select="//added-source">
               <xsl:variable name="qstat" select="@status"/>
               <xsl:choose>
                  <xsl:when test="$qstat = 'queried'">
                     <xsl:value-of select="@retrieved"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>0</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getqueryretrieved">
      <xsl:variable name="ascount" select="count(//added-source)"/>
      <xsl:choose>
         <xsl:when test="$ascount > 0">
            <xsl:for-each select="//added-source">
               <xsl:variable name="qstat" select="@status"/>
               <xsl:choose>
                  <xsl:when test="$qstat = 'queried'">
                     <xsl:value-of select="@retrieved"/>
                     <xsl:if test="$ascount > 1">
                        <xsl:text>&#xa;</xsl:text>
                     </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>0</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getqueryrequested">
      <xsl:choose>
         <xsl:when test="count(//added-source) > 0">
            <xsl:for-each select="//added-source">
               <xsl:variable name="qstat" select="@status"/>
               <xsl:choose>
                  <xsl:when test="$qstat = 'queried'">
                     <xsl:value-of select="@requested"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>0</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getquerypageurls">
      <xsl:if test="count(//added-source/parse) > 0">
         <xsl:for-each select="//added-source/parse">
            <xsl:value-of select="@url"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getqueryurls">
      <xsl:if test="count(//document) > 0">
         <xsl:for-each select="//document">
            <xsl:value-of select="@url"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="getqueryurlsbyrank">
      <xsl:if test="count(//document) > 0"> 
         <xsl:for-each select="//document">
            <xsl:variable name="arank" select="@rank"/>
            <xsl:variable name="aurl" select="@url"/>
            <xsl:if test="$arank = string($mytrib)">
               <xsl:value-of select="$aurl"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
   </xsl:template>

   <xsl:template name="jidstatus">
      <xsl:choose>
         <xsl:when test="count(//source) > 0">
            <xsl:for-each select="//source">
               <xsl:variable name="anid" select="@job-id"/>
               <xsl:variable name="aurl" select="@status"/>
               <xsl:if test="$anid = string($mytrib)">
                  <xsl:value-of select="$aurl"/>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>job not found</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="dictionary-build-status">
      <xsl:value-of select="//dictionary-status/@status"/>
   </xsl:template>

   <xsl:template name="repo-item-content">
      <xsl:choose>
         <xsl:when test="$mytrib = 'testnode'" >
            <xsl:value-of select="//testnode/content"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'md5'" >
            <xsl:value-of select="//md5"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>NO_NAME_FOUND</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="repo-item-name">
      <xsl:choose>
         <xsl:when test="$mytrib = 'testnode'" >
            <xsl:value-of select="//testnode/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'exception'" >
            <xsl:value-of select="//exception/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'application'" >
            <xsl:value-of select="//application/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'kb'" >
            <xsl:value-of select="//kb/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'dictionary'" >
            <xsl:value-of select="//dictionary/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'macro'" >
            <xsl:value-of select="//macro/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'parser'" >
            <xsl:value-of select="//parser/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'report'" >
            <xsl:value-of select="//report/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'collection'" >
            <xsl:value-of select="//vse-collection/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'source'" >
            <xsl:value-of select="//source/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'function'" >
            <xsl:value-of select="//function/@name"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'form'" >
            <xsl:value-of select="//form/@name"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>NO_NAME_FOUND</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="collection-node-count">
      <xsl:choose>
         <xsl:when test="$mytrib = 'vseconfig'" >
            <xsl:value-of select="count(//vse-collection/vse-config)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'vsestatus'" >
            <xsl:value-of select="count(//vse-collection/vse-status)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'crawlconfig'" >
            <xsl:value-of select="count(//vse-collection/vse-config/crawler)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'indexconfig'" >
            <xsl:value-of select="count(//vse-collection/vse-config/vse-index)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'converters'" >
            <xsl:value-of select="count(//vse-collection/vse-config/converters)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'crawlstatus'" >
            <xsl:value-of select="count(//vse-collection/vse-status/crawler-status)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'indexstatus'" >
            <xsl:value-of select="count(//vse-collection/vse-status/vse-index-status)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'runconfig'" >
            <xsl:value-of select="count(//vse-collection/vse-run)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'collectionservicestatus'" >
            <xsl:value-of select="count(//vse-collection/collection-service-status)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="count-repo-list-content">
      <xsl:choose>
         <xsl:when test="$mytrib = 'application'" >
            <xsl:value-of select="count(//application)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'kb'" >
            <xsl:value-of select="count(//kb)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'dictionary'" >
            <xsl:value-of select="count(//dictionary)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'macro'" >
            <xsl:value-of select="count(//macro)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'parser'" >
            <xsl:value-of select="count(//parser)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'report'" >
            <xsl:value-of select="count(//report)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'collection'" >
            <xsl:value-of select="count(//vse-collection)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'source'" >
            <xsl:value-of select="count(//source)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'function'" >
            <xsl:value-of select="count(//function)"/>
         </xsl:when>
         <xsl:when test="$mytrib = 'form'" >
            <xsl:value-of select="count(//form)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="status-started">
      <xsl:variable name="starttime"
       select="count(//vse-qs-status/service-status/@started)"/>
      <xsl:choose>
         <xsl:when test="$starttime > 0" >
            <xsl:value-of select="//vse-qs-status/service-status/@started"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="status-ping">
      <xsl:variable name="pingcnt"
       select="count(//ping)"/>
      <xsl:choose>
         <xsl:when test="$pingcnt > 0" >
            <xsl:value-of select="//ping/@install-dir"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Ping Failed</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="getindexfilecount">
      <xsl:variable name="index-files"
        select="//vse-status[@which='live']/vse-index-status/vse-index-file"
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
       select="//vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/vse-index-status"/>
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
       select="//vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/vse-index-status"/>
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
       select="//vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/vse-index-status"/>
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
       select="//vse-status[@which='live']/vse-index-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/vse-index-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
       select="//vse-status[@which='live']/crawler-status"/>
      <xsl:variable name="stagdata"
       select="//vse-status[@which='staging']/crawler-status"/>
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
        select="//vse-status[@which='live']/vse-index-status"
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
        select="//vse-status[@which='live']/vse-index-status"
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


   <!--   ##############################################################  -->
   <xsl:template match="/">
      <xsl:choose>
         <xsl:when test="$mynode = 'search-service-status'">
            <xsl:call-template name="status-started"/>
         </xsl:when>
         <xsl:when test="$mynode = 'search-service-ping'">
            <xsl:call-template name="status-ping"/>
         </xsl:when>
         <xsl:when test="$mynode = 'repo-list'">
            <xsl:call-template name="count-repo-list-content"/>
         </xsl:when>
         <xsl:when test="$mynode = 'job-id-list'">
            <xsl:call-template name="jidlist"/>
         </xsl:when>
         <xsl:when test="$mynode = 'jid-status'">
            <xsl:call-template name="jidstatus"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-cluster-list'">
            <xsl:call-template name="getqueryclustertree"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-cluster-count'">
            <xsl:call-template name="getqueryclustercount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-url-list'">
            <xsl:call-template name="getqueryurls"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-page-list'">
            <xsl:call-template name="getquerypageurls"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-url-count'">
            <xsl:call-template name="getqueryurlcount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-string'">
            <xsl:call-template name="getqueryquery"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-page-count'">
            <xsl:call-template name="getquerypagecount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-result-count'">
            <xsl:call-template name="getquerytotalresults"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-result-file'">
            <xsl:call-template name="getqueryresultfile"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-retrieve-count'">
            <xsl:call-template name="getqueryretrieved"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-request-count'">
            <xsl:call-template name="getqueryrequested"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query-operator'">
            <xsl:call-template name="getqueryoperator"/>
         </xsl:when>
         <xsl:when test="$mynode = 'dictionary-status'">
            <xsl:call-template name="dictionary-build-status"/>
         </xsl:when>
         <xsl:when test="$mynode = 'repo-item'">
            <xsl:call-template name="repo-item-name"/>
         </xsl:when>
         <xsl:when test="$mynode = 'collection-item-count'">
            <xsl:call-template name="collection-node-count"/>
         </xsl:when>
         <xsl:when test="$mynode = 'repo-content'">
            <xsl:call-template name="repo-item-content"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-size'">
            <xsl:call-template name="getindexsize"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-errors'">
            <xsl:call-template name="getcrawlerrors"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-outputs'">
            <xsl:call-template name="getcrawloutputs"/>
         </xsl:when>
         <xsl:when test="$mynode = 'crawl-pending'">
            <xsl:call-template name="getcrawlpending"/>
         </xsl:when>
         <xsl:when test="$mynode = 'index-docs'">
            <xsl:call-template name="getindexeddocs"/>
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
         <xsl:when test="$mynode = 'content-item-count'">
            <xsl:call-template name="getitemcount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'document-attr-count'">
            <xsl:call-template name="getdocattrcount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'document-attr-value'">
            <xsl:call-template name="getdocattrvalues"/>
         </xsl:when>
         <xsl:when test="$mynode = 'cache-url-count'">
            <xsl:call-template name="getcacheurlcount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'cache-data-count'">
            <xsl:call-template name="getcachedatacount"/>
         </xsl:when>
         <xsl:when test="$mynode = 'content-values'">
            <xsl:call-template name="getcontentvalues"/>
         </xsl:when>
         <xsl:when test="$mynode = 'content-attr-values'">
            <xsl:call-template name="getcontentattrvalues"/>
         </xsl:when>
         <xsl:when test="$mynode = 'content-attr-values-by-name'">
            <xsl:call-template name="getcontentattrvaluesbyname"/>
         </xsl:when>
         <xsl:when test="$mynode = 'cbs-collection-attr-values-by-name'">
            <xsl:call-template name="getcbscollectionattrvaluesbyname"/>
         </xsl:when>
         <xsl:when test="$mynode = 'cbs-collection-list'">
            <xsl:call-template name="getcbscollectionnames"/>
         </xsl:when>
         <xsl:when test="$mynode = 'cb-collection-service-status'">
            <xsl:call-template name="getcbcollectionservicestatus"/>
         </xsl:when>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
