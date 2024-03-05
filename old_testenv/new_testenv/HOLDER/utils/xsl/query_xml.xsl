<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--   ###########################################################  -->
<!--   Everything in this file processes the xml returned by a      -->
<!--   query.                                                       -->
<!--   ###########################################################  -->

<!--   ###########################################################  -->
<!--   Make the output be raw text.  This way we don't get that     -->
<!--   Irritating <?xml version="1.0"?> line as the first line      -->
<!--   of output.                                                   -->
<xsl:output method="text"/>

<!--  which command to execute  -->
<xsl:param name="mynode" as="xs:string"/>

<!--  parameter type (if needed)  -->
<xsl:param name="which" as="xs:string"/>

<!--  value paramter of command or type parameter  -->
<xsl:param name="value" as="xs:string"/>

   <xsl:template name="get_url_match_counts">
      <xsl:for-each select="//document">
         <xsl:sort select="@url"/>
         <xsl:value-of select="@url"/>
         <xsl:variable name="matchit" select="count(.//match)"/>
         <xsl:text>:::::matches=</xsl:text>
         <xsl:value-of select="$matchit"/>
         <xsl:text>&#xa;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="get_url_matches">
      <xsl:for-each select="//document">
         <xsl:sort select="@url"/>
         <xsl:value-of select="@url"/>
         <xsl:text>&#xa;</xsl:text>
         <xsl:for-each select=".//content/solution">
            <xsl:variable name="matchit" select="match"/>
            <xsl:text>   MATCH:  </xsl:text>
            <xsl:value-of select="$matchit"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="get_content_titles">
      <xsl:variable name="mycontent" select="//document/content"/>
      <xsl:choose>
         <xsl:when test="count($mycontent) > 0">
            <xsl:for-each select="//document">
               <xsl:sort select="@url"/>
               <xsl:for-each select="./content">
                  <xsl:if test="./@name = 'title'">
                     <xsl:value-of select="."/>
                     <xsl:text>&#xa;</xsl:text>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Empty</xsl:text>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="count_content_item">
      <xsl:variable name="mycontent"
           select="count(//document/content[@name=$which])"/>
      <xsl:choose>
         <xsl:when test="$mycontent > 0">
            <xsl:value-of select="$mycontent"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_content_snippets">
      <xsl:variable name="mycontent" select="//document/content"/>
      <xsl:choose>
         <xsl:when test="count($mycontent) > 0">
            <xsl:for-each select="//document">
               <xsl:for-each select="./content">
                  <xsl:if test="./@name = 'snippet'">
                     <xsl:value-of select="."/>
                     <xsl:text>&#xa;</xsl:text>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_content_duplicates">
      <xsl:variable name="mycontent" select="//document/duplicate-documents"/>
      <xsl:choose>
         <xsl:when test="count($mycontent) > 0">
            <xsl:for-each select="//document/duplicate-documents">
               <xsl:for-each select="./document">
                  <xsl:value-of select="@url"/>
                  <xsl:text>&#xa;</xsl:text>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="count_content_duplicates">
      <xsl:variable name="mycontent" select="//document/duplicate-documents/document"/>
      <xsl:choose>
         <xsl:when test="count($mycontent) > 0">
            <xsl:value-of select="count($mycontent)"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
            <xsl:text>&#xa;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_url_count">
      <xsl:variable name="totcnt" select="//attribute[@name='total-results']"/>
      <xsl:choose>
         <xsl:when test="count($totcnt) > 0">
            <xsl:value-of select="$totcnt/@value"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="numcnt" select="//added-source/@total-results"/>
            <xsl:choose>
               <xsl:when test="$numcnt > 0">
                  <xsl:value-of select="$numcnt"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>0</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_url_by_content">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:variable name="aurl" select="@url"/>
               <xsl:for-each select="content[@name=string($which)]">
                  <xsl:variable name="curval" select="."/>
                  <xsl:if test="string($curval) = string($value)">
                     <xsl:value-of select="$aurl"/>
                     <xsl:text>&#xa;</xsl:text>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:variable name="aurl" select="@url"/>
               <xsl:for-each select="content[@name=string($which)]">
                  <xsl:variable name="curval" select="."/>
                  <xsl:if test="string($curval) = string($value)">
                     <xsl:value-of select="$aurl"/>
                     <xsl:text>&#xa;</xsl:text>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_shingles">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:sort select="@mwi-shingle"/>
               <xsl:value-of select="@mwi-shingle"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:sort select="@mwi-shingle"/>
               <xsl:value-of select="@mwi-shingle"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_query_file">
      <xsl:for-each select="//declare">
         <xsl:if test="@name = string('file')">
            <xsl:value-of select="@initial-value"/>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="get_url_by_id">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:variable name="anid" select="@id"/>
               <xsl:variable name="aurl" select="@url"/>
               <xsl:if test="$anid = string($value)">
                  <xsl:value-of select="$aurl"/>
                  <xsl:text>&#xa;</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:variable name="anid" select="@id"/>
               <xsl:variable name="aurl" select="@url"/>
               <xsl:if test="$anid = string($value)">
                  <xsl:value-of select="$aurl"/>
                  <xsl:text>&#xa;</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_ids">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:value-of select="@id"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:value-of select="@id"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_vse_scores">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:value-of select="@vse-base-score"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:value-of select="@vse-base-score"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_scores">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:value-of select="@score"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:value-of select="@score"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_vse-key">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:value-of select="@vse-key"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:value-of select="@vse-key"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_urls">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_url_sorted_by_score">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:sort select="@vse-base-score"/>
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:sort select="@vse-base-score"/>
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_url_sorted_by_link_score">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:sort select="@la-score"/>
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:sort select="@la-score"/>
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_sorted_urls">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:for-each select="//list//document">
               <xsl:sort select="@url"/>
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="//document">
               <xsl:sort select="@url"/>
               <xsl:value-of select="@url"/>
               <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="get_a_url">
      <xsl:for-each select="//document">
         <xsl:if test="position() = $value">
            <xsl:value-of select="@url"/>
            <xsl:text>&#xa;</xsl:text>
         </xsl:if>
      </xsl:for-each>
   </xsl:template>

   <xsl:template name="get_bin_url_count">
      <xsl:variable name="bincnt"
           select="//binning/binning-set/bin[@label=string($value)]"/>
      <xsl:variable name="actual_cnt"
           select="count($bincnt)"/>
      <xsl:choose>
         <xsl:when test="$actual_cnt > 0">
            <xsl:for-each select="$bincnt">
               <xsl:value-of select="@ndocs"/>
               <xsl:if test="$actual_cnt > 1">
                  <xsl:text>&#xa;</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="holder">
      <xsl:variable name="bincnt"
           select="//binning/binning-set/bin[@label=string($value)]"/>
      <xsl:choose>
         <xsl:when test="count($bincnt) > 0">
            <xsl:value-of select="$bincnt/@ndocs"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="count_the_urls">
      <xsl:choose>
         <xsl:when test="count(//list//document) > 0">
            <xsl:variable name="url_count" select="//list//document/@url"/>
            <xsl:value-of select="count($url_count)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="url_count" select="//document/@url"/>
            <xsl:value-of select="count($url_count)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template match="/">
      <xsl:choose>
         <!--   Get the url count from "total-results" -->
         <xsl:when test="$mynode = 'url_count'">
            <xsl:call-template name="get_url_count"/>
         </xsl:when>
         <!--   Get the url count by counting the actual urls -->
         <xsl:when test="$mynode = 'count_urls'">
            <xsl:call-template name="count_the_urls"/>
         </xsl:when>
         <!--   Get the url by document id  -->
         <xsl:when test="$mynode = 'url_by_id'">
            <xsl:call-template name="get_url_by_id"/>
         </xsl:when>
         <!--   Get the urls and dump them -->
         <xsl:when test="$mynode = 'urls'">
            <xsl:call-template name="get_urls"/>
         </xsl:when>
         <!--   Get the urls and dump them sorted -->
         <xsl:when test="$mynode = 'sort_urls'">
            <xsl:call-template name="get_sorted_urls"/>
         </xsl:when>
         <!--   Get a single url as requested by "value" parameter -->
         <!--   (numeric by position, i.e., 3 will get the third url) -->
         <xsl:when test="$mynode = 'get_one_url'">
            <xsl:call-template name="get_a_url"/>
         </xsl:when>
         <!--   For simple query bins, get the number of docs in the bin -->
         <!--   value is specified by "value" parameter  -->
         <!--   (i.e., "stringparam value Battleship")   -->
         <xsl:when test="$mynode = 'bin_url_count'">
            <xsl:call-template name="get_bin_url_count"/>
         </xsl:when>
         <!--   For simple query bins, get the number urls which have the -->
         <!--   specified content name (which) and content value (value)  -->
         <!--   So, this one need three stringparams to work  -->
         <xsl:when test="$mynode = 'url_by_content'">
            <xsl:call-template name="get_url_by_content"/>
         </xsl:when>
         <xsl:when test="$mynode = 'matches'">
            <xsl:call-template name="get_url_matches"/>
         </xsl:when>
         <xsl:when test="$mynode = 'url_by_score'">
            <xsl:call-template name="get_url_sorted_by_score"/>
         </xsl:when>
         <xsl:when test="$mynode = 'scores'">
            <xsl:call-template name="get_scores"/>
         </xsl:when>
         <xsl:when test="$mynode = 'snippets'">
            <xsl:call-template name="get_content_snippets"/>
         </xsl:when>
         <xsl:when test="$mynode = 'duplicates'">
            <xsl:call-template name="get_content_duplicates"/>
         </xsl:when>
         <xsl:when test="$mynode = 'count_duplicates'">
            <xsl:call-template name="count_content_duplicates"/>
         </xsl:when>
         <xsl:when test="$mynode = 'url_by_link_score'">
            <xsl:call-template name="get_url_sorted_by_link_score"/>
         </xsl:when>
         <xsl:when test="$mynode = 'match_counts'">
            <xsl:call-template name="get_url_match_counts"/>
         </xsl:when>
         <xsl:when test="$mynode = 'query_file'">
            <xsl:call-template name="get_query_file"/>
         </xsl:when>
         <xsl:when test="$mynode = 'content_titles'">
            <xsl:call-template name="get_content_titles"/>
         </xsl:when>
         <xsl:when test="$mynode = 'item_count'">
            <xsl:call-template name="count_content_item"/>
         </xsl:when>
         <xsl:when test="$mynode = 'get_document_shingles'">
            <xsl:call-template name="get_shingles"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>0</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

</xsl:stylesheet>
