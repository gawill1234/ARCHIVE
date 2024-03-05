require 'test_helper' 

def qe_basic_test_setup()
  vlog "QE basic setup: ensure collections are crawled and index is running and load query-expansion API function (not yet part of the product)"

  prepare_crawl('ontolection-english-spelling-variations')
  prepare_crawl('ontolection-english-general-basic-example')
  prepare_crawl('ontolection-english-general-advanced-example')

# need to update expand_query_selected_terms_api -> <with name="query-expansion.stemming-weight" value="{$query-expansion.stemming-weight}" />
# when updating functions below, make sure to copy the inital-values, otherwise tests will fail (it expects spanish and other relationships to be enabled)
############
  begin
    vlog "Deleting query-expand and display api function from repository"
    @vapi.repository_delete({:element => "function", :name => 'query-expand'})
  rescue
  end
  query_expand = <<HERE
<function max-elt-id="1438" name="query-expand" type="public-api" products="core" modified-by="font" modified="1259008863">
  <prototype>
    <description>Initial prototype. Still need to discuss this and commit.
Takes a query object (node) and returns the expanded query node. It can either output (i) a temporary node to be interpreted by a display module, that shows what expansions are being added to the original query in addition to what expansions are being suggested, (ii) the final expanded query node containing only the original terms and expansions to be automatically added as specified by the parameters and by end-user changes to the displayed node, or (iii) both.</description>
    <declare name="query" type="string" />
    <declare name="query-node" type="nodeset">
      <!--
      <initial-value>
        <operator logic="and">
          <term field="query" str="baby" position="0" processing="strict" input-type="user" />
        </operator>
      </initial-value>
-->
      <label>Query node</label>
    </declare>
    <declare name="output-node-type" enum-values="display|final|both" type="enum" initial-value="final" />
    <declare name="query-expansion.ontolections" type="string" initial-value="ontolection-english-spelling-variations ontolection-english-general-basic-example ontolection-english-general-advanced-example" />
    <declare name="query-expansion.automatic-symmetric" type="separated-set" type-separator="|" initial-value="synonym:0.8|spelling:0.8|acronym-synonym|health-synonym|economy-synonym" />
    <declare name="query-expansion.automatic-asymmetric" type="separated-set" type-separator="|" initial-value="narrower:0.5|data-narrower|energy-narrower|rewrite" />
    <declare name="query-expansion.suggestion-symmetric" type="separated-set" type-separator="|" initial-value="translation:0.5|spanish" />
    <declare name="query-expansion.suggestion-asymmetric" type="separated-set" type-separator="|" initial-value="broader:0.3|related:0.2" />
    <declare name="query-expansion.stem-expansions" type="boolean" initial-value="false" />
    <declare name="query-expansion.stemming-weight" type="number" initial-value="0.5" />
    <declare name="query-expansion.stemming-dictionary" type="string" initial-value="english/wildcard.dict" />
    <declare name="query-expansion.max-terms-per-type" type="number" initial-value="5" />
    <declare name="query-expansion.infer-inverse-relations" type="boolean" initial-value="true" />
    <declare enum-values="terms|exact|exact-terms" name="query-expansion.query-match-type" type="enum" initial-value="exact-terms" />
    <declare name="query-expansion.conceptual-search-metric" enum-values="dice|euclidean-dot-product" initial-value="euclidean-dot-product" tag="set-var" type="enum" />
    <declare name="query-expansion.conceptual-search-similarity-threshold" type="number" initial-value="0.5" />
    <declare name="query-expansion.user-profile" type="enum" enum-values="system-default|suggestions-only|off" initial-value="system-default" />
  </prototype>
  <choose>
    <!-- first time query is called with this api function (original query, not revised expanded query) -->
    <when test="not($query-expansion.user-profile='off') and not(viv:value-of('revised', 'state-param'))">
      <declare name="entered-query" type="nodeset" />
      <set-var name="entered-query">
        <choose>
          <when test="$query-node">
            <query>
              <copy-of select="$query-node" />
            </query>
          </when>
          <!-- augment this for multiword queries, ops, etc.) -->
          <otherwise>
            <query>
              <operator logic="and">
                <term field="query">
                  <attribute name="str">
                    <value-of select="$query" />
                  </attribute>
                </term>
              </operator>
            </query>
          </otherwise>
        </choose>
      </set-var>
      <if test="$entered-query/operator//term[@field='query']">
        <declare name="expanded-query" type="nodeset" />
        <set-var name="expanded-query">
          <call-function name="expand-query">
            <with name="query">
              <copy-of select="$entered-query" />
            </with>
            <with name="query-expansion.max-terms-per-type" value="{$query-expansion.max-terms-per-type}" />
            <with name="query-expansion.automatic-symmetric" value="{$query-expansion.automatic-symmetric}" />
            <with name="query-expansion.suggestion-symmetric" value="{$query-expansion.suggestion-symmetric}" />
            <with name="query-expansion.automatic-asymmetric" value="{$query-expansion.automatic-asymmetric}" />
            <with name="query-expansion.suggestion-asymmetric" value="{$query-expansion.suggestion-asymmetric}" />
            <with name="query-expansion.infer-inverse-relations" value="{$query-expansion.infer-inverse-relations}" />
            <with name="query-expansion.query-match-type" value="{$query-expansion.query-match-type}" />
            <with name="query-expansion.ontolections" value="{$query-expansion.ontolections}" />
            <with name="query-expansion.conceptual-search-metric" value="{$query-expansion.conceptual-search-metric}" />
            <with name="query-expansion.conceptual-search-similarity-threshold" value="{$query-expansion.conceptual-search-similarity-threshold}" />
            <with name="query-expansion.user-profile" value="{$query-expansion.user-profile}" />
          </call-function>
        </set-var>
        <call-function name="expand-query-selected-terms-api-alpha">
          <with name="query">
            <copy-of select="$expanded-query" />
          </with>
          <with name="query-expansion.automatic-symmetric" value="{$query-expansion.automatic-symmetric}" />
          <with name="query-expansion.suggestion-symmetric" value="{$query-expansion.suggestion-symmetric}" />
          <with name="query-expansion.automatic-asymmetric" value="{$query-expansion.automatic-asymmetric}" />
          <with name="query-expansion.suggestion-asymmetric" value="{$query-expansion.suggestion-asymmetric}" />
          <with name="query-expansion.stem-expansions" value="{$query-expansion.stem-expansions}" />
          <with name="query-expansion.stemming-weight" value="{$query-expansion.stemming-weight}" />
          <with name="query-expansion.stemming-dictionary" value="{$query-expansion.stemming-dictionary}" />
          <with name="query-expansion.query-match-type" value="{$query-expansion.query-match-type}" />
          <with name="query-expansion.user-profile" value="{$query-expansion.user-profile}" />
          <with name="used-terms" value="{viv:value-of('term', 'state-param', '#')}" />
          <with name="revised" value="{viv:value-of('revised', 'state-param')}" />
          <with name="output-node-type" value="{$output-node-type}" />
        </call-function>
      </if>
    </when>
    <!-- expanded query has been revised by end-user (expansions have been checked/unchecked) -->
    <when test="not($query-expansion.user-profile='off') and viv:value-of('revised', 'state-param')">
      <query>
        <copy-of select="$query" />
      </query>
      <call-function name="expand-query-selected-terms-api-alpha">
        <with name="query">
          <copy-of select="viv:str-to-node(viv:value-of('qe-xml', 'state-param'))" />
        </with>
        <with name="query-expansion.automatic-symmetric" value="{$query-expansion.automatic-symmetric}" />
        <with name="query-expansion.suggestion-symmetric" value="{$query-expansion.suggestion-symmetric}" />
        <with name="query-expansion.automatic-asymmetric" value="{$query-expansion.automatic-asymmetric}" />
        <with name="query-expansion.suggestion-asymmetric" value="{$query-expansion.suggestion-asymmetric}" />
        <with name="query-expansion.stem-expansions" value="{$query-expansion.stem-expansions}" />
        <with name="query-expansion.stemming-weight" value="{$query-expansion.stemming-weight}" />
        <with name="query-expansion.stemming-dictionary" value="{$query-expansion.stemming-dictionary}" />
        <with name="query-expansion.query-match-type" value="{$query-expansion.query-match-type}" />
        <with name="query-expansion.user-profile" value="{$query-expansion.user-profile}" />
        <with name="used-terms" value="{viv:value-of('term', 'state-param', '#')}" />
        <with name="revised" value="{viv:value-of('revised', 'state-param')}" />
        <with name="output-node-type" value="{$output-node-type}" />
      </call-function>
    </when>
  </choose>
</function>
HERE

  begin
    @vapi.repository_delete({:element => "function", :name => 'expand-query-selected-terms-api-alpha'})
  rescue
  end
  expand_query_selected_terms_api = "<function max-elt-id=\"161\" name=\"expand-query-selected-terms-api-alpha\" modified=\"1244559568\" modified-by=\"font@Vivisimo, Inc\">
  <prototype>
    <declare name=\"query\" type=\"nodeset\" />
    <declare name=\"query-now\" type=\"nodeset\" />
    <declare name=\"query-expansion.automatic-symmetric\" type=\"separated-set\" type-separator=\"|\" />
    <declare name=\"query-expansion.automatic-asymmetric\" type=\"separated-set\" type-separator=\"|\" />
    <declare name=\"query-expansion.suggestion-symmetric\" type=\"separated-set\" type-separator=\"|\" />
    <declare name=\"query-expansion.suggestion-asymmetric\" type=\"separated-set\" type-separator=\"|\" />
    <declare name=\"query-expansion.stem-expansions\" type=\"boolean\" initial-value=\"false\" />
    <declare name=\"query-expansion.stemming-dictionary\" type=\"string\" />
    <declare name=\"query-expansion.stemming-weight\" type=\"number\" />
    <declare name=\"query-expansion.max-terms-per-type\" type=\"number\" />
    <declare enum-values=\"terms|exact|exact-terms\" name=\"query-expansion.query-match-type\" type=\"enum\" />
    <declare name=\"query-expansion.user-profile\" type=\"string\" />
    <declare name=\"used-terms\" type=\"string\" />
    <declare name=\"revised\" type=\"string\" />
    <!-- for api debugging -->
    <declare name=\"output-node-type\" enum-values=\"both|display|final\" type=\"enum\" initial-value=\"both\" />
  </prototype>
  <process-xsl><![CDATA[
  <xsl:param name=\"query\"/>
  <xsl:param name=\"query-now\" />
  <xsl:param name=\"query-expansion.automatic-symmetric\"/>
  <xsl:param name=\"query-expansion.automatic-asymmetric\"/>
  <xsl:param name=\"query-expansion.suggestion-symmetric\"/>
  <xsl:param name=\"query-expansion.suggestion-asymmetric\"/>
  <xsl:param name=\"query-expansion.stem-expansions\"/>
  <xsl:param name=\"query-expansion.stemming-dictionary\" />
  <xsl:param name=\"query-expansion.stemming-weight\" />
  <xsl:param name=\"query-expansion.max-terms-per-type\"/>
  <xsl:param name=\"query-expansion.query-match-type\"/>
  <xsl:param name=\"query-expansion.user-profile\" />
  <xsl:param name=\"used-terms\" />
  <xsl:param name=\"revised\" />
  <xsl:param name=\"output-node-type\" />
  <xsl:variable name=\"auto-sym\" select=\"str:split(viv:replace($query-expansion.automatic-symmetric, ' ', '','g'), '|')\" /> 
  <xsl:variable name=\"auto-asym\" select=\"str:split(viv:replace($query-expansion.automatic-asymmetric, ' ', '','g'), '|')\" />
  <xsl:variable name=\"suggest-sym\" select=\"str:split(viv:replace($query-expansion.suggestion-symmetric, ' ', '','g'), '|')\" />
  <xsl:variable name=\"suggest-asym\" select=\"str:split(viv:replace($query-expansion.suggestion-asymmetric, ' ', '','g'), '|')\" />
  <xsl:variable name=\"auto-sym-temp\">
   <xsl:if test=\"$query-expansion.stem-expansions=true()\">
   <xsl:for-each select=\"$auto-sym\" >
         <token>
            <xsl:value-of select=\"concat(normalize-space(str:split(., ':')[1]), '+stemming')\" />
         </token>
    </xsl:for-each>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name=\"auto-sym-stem\" select=\"exsl:node-set($auto-sym-temp)\" />
  <xsl:variable name=\"auto-asym-temp\">
   <xsl:if test=\"$query-expansion.stem-expansions=true()\">
   <xsl:for-each select=\"$auto-asym\" >
         <token>
            <xsl:value-of select=\"concat(normalize-space(str:split(., ':')[1]), '+stemming')\" />
         </token>
    </xsl:for-each>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name=\"auto-asym-stem\" select=\"exsl:node-set($auto-asym-temp)\" />

  <xsl:variable name=\"suggest-sym-temp\">
   <xsl:if test=\"$query-expansion.stem-expansions=true()\">
   <xsl:for-each select=\"$suggest-sym\" >
         <token>
            <xsl:value-of select=\"concat(normalize-space(str:split(., ':')[1]), '+stemming')\" />
         </token>
    </xsl:for-each>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name=\"suggest-sym-stem\" select=\"exsl:node-set($suggest-sym-temp)\" />
  <xsl:variable name=\"suggest-asym-temp\">
   <xsl:if test=\"$query-expansion.stem-expansions=true()\">
   <xsl:for-each select=\"$suggest-asym\" >
      <token>
         <xsl:value-of select=\"concat(normalize-space(str:split(., ':')[1]), '+stemming')\" />
      </token>
    </xsl:for-each>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name=\"suggest-asym-stem\" select=\"exsl:node-set($suggest-asym-temp)\" />
  <xsl:variable name=\"used-terms-node\" select=\"str:split($used-terms, '#')\" />

  <xsl:template match=\"/\">
    <xsl:variable name=\"expanded-query\">
        <xsl:choose>
          <xsl:when test=\"$query-expansion.stem-expansions=true()\">
             <xsl:apply-templates select=\"$query/op-exp|$query/operator\" mode=\"stemming-expansion\" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select=\"$query\" />
         </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>   

<!-- change this to not output it when calling this function from api function -->
    <xsl:if test=\"$output-node-type != 'final'\" >
       <xsl:copy-of select=\"exsl:node-set($expanded-query)\" />
    </xsl:if>
    <xsl:choose>
     <!-- query has not been expanded, still need to output a node; commenting out for csol testing -->
      <xsl:when test=\"not(exsl:node-set($expanded-query)//term[@relation])\">
        <xsl:apply-templates select=\"exsl:node-set($query)\" mode=\"vxml-format\" />
      </xsl:when>
      <xsl:when test=\"$query-expansion.query-match-type='exact-terms' and count($used-terms-node)=0 and exsl:node-set($expanded-query)//op-exp[count(./term)>1 and ./term[@implicit-phrase='true']]\">
<!-- there are implicit phrases, so the individual words' expansions should not be used. -->
        <xsl:variable name=\"set-individ-terms-to-false\">
          <query>
            <op-exp logic=\"and\">
              <op-exp logic=\"or\" middle-string=\"OR\" name=\"OR\" precedence=\"2\">
                <xsl:apply-templates select=\"exsl:node-set($expanded-query)/query/op-exp/op-exp/op-exp[term[@implicit-phrase='true']]\" mode=\"get-revised-selected\" />
                <xsl:apply-templates select=\"exsl:node-set($expanded-query)/query/op-exp/op-exp/op-exp[not(term[@implicit-phrase='true'])]\" mode=\"exact-terms-set-false\" />
              </op-exp>
            </op-exp>
          </query>
        </xsl:variable>
        <xsl:choose>
         <xsl:when test=\"$output-node-type='both'\">
           <!-- display node -->
           <xsl:copy-of select=\"exsl:node-set($set-individ-terms-to-false)\" />
           <!-- final node -->
           <xsl:apply-templates select=\"exsl:node-set($set-individ-terms-to-false)\" mode=\"vxml-format\" />
         </xsl:when>
         <xsl:when test=\"$output-node-type='display'\">
            <xsl:copy-of select=\"exsl:node-set($set-individ-terms-to-false)\" />
         </xsl:when>
         <xsl:otherwise> <!-- final node -->
            <xsl:apply-templates select=\"exsl:node-set($set-individ-terms-to-false)\" mode=\"vxml-format\" />
         </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:when test=\"$query-expansion.query-match-type='exact-terms' and count($used-terms-node)=0 and exsl:node-set($expanded-query)//op-exp[count(./term)=1 and ./term[@implicit-phrase='true']]\">
<!-- there are not implicit phrase expansions, so ignore the operator that has the implicit phrase term and get rid of the extra logic. -->
        <xsl:variable name=\"total\">
          <query>
            <xsl:apply-templates select=\"exsl:node-set($expanded-query)/query/op-exp/op-exp/op-exp[not(term[@implicit-phrase])]\" mode=\"get-revised-selected\" />
          </query>
        </xsl:variable>
        <xsl:copy-of select=\"exsl:node-set($total)\" />
        <xsl:apply-templates select=\"exsl:node-set($total)\" mode=\"vxml-format\" />
      </xsl:when>
      <xsl:when test=\"$revised='1'\">
          <xsl:variable name=\"total\">
            <query>
              <xsl:apply-templates select=\"exsl:node-set($expanded-query)/query/op-exp|exsl:node-set($expanded-query)/query/operator\" mode=\"get-revised-selected\" />
            </query>
          </xsl:variable>
        <xsl:choose>
         <xsl:when test=\"$output-node-type='both'\">
           <!-- display node -->
           <xsl:copy-of select=\"exsl:node-set($total)\" />
           <!-- final node -->
           <xsl:apply-templates select=\"exsl:node-set($total)\" mode=\"vxml-format\" />
         </xsl:when>
         <xsl:when test=\"$output-node-type='display'\">
            <xsl:copy-of select=\"exsl:node-set($total)\" />
         </xsl:when>
         <xsl:otherwise> <!-- final node -->
            <xsl:apply-templates select=\"exsl:node-set($total)\" mode=\"vxml-format\" />
         </xsl:otherwise>
       </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
<!-- normal query, no implicit phrases. just set use=true/false according to the settings or the checked terms. -->
        <xsl:variable name=\"total\">
          <query>
            <xsl:apply-templates select=\"exsl:node-set($expanded-query)/query/op-exp\" mode=\"get-revised-selected\" />
          </query>
        </xsl:variable>
        <xsl:choose>
         <xsl:when test=\"$output-node-type='both'\">
           <xsl:copy-of select=\"exsl:node-set($total)\" />
           <xsl:apply-templates select=\"exsl:node-set($total)\" mode=\"vxml-format\" />
         </xsl:when>
         <xsl:when test=\"$output-node-type='display'\">
            <xsl:copy-of select=\"exsl:node-set($total)\" />
         </xsl:when>
         <xsl:otherwise> <!-- final node -->
            <xsl:apply-templates select=\"exsl:node-set($total)\" mode=\"vxml-format\" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template match=\"op-exp\" mode=\"get-revised-selected\">
    <xsl:choose>
      <xsl:when test=\"count(term)=1 and term[@implicit-phrase='true'] and ($auto-sym='original:0' or $auto-asym='original:0' or $suggest-sym='original:0' or $suggest-asym='original:0') and $query-expansion.query-match-type='exact'\">
        <xsl:variable name=\"original-terms\" select=\"str:tokenize(term/@str)\" />
        <op-exp>
          <xsl:copy-of select=\"@*\" />
          <xsl:for-each select=\"$original-terms\"> 
            <term field=\"query\" str=\"{.}\" processing=\"strict\" use=\"true\" />
          </xsl:for-each>
        </op-exp>
      </xsl:when>
      <xsl:when test=\"count(term)>1 and term[@implicit-phrase='true'] and ($auto-sym='original:0' or $auto-asym='original:0' or $suggest-sym='original:0' or $suggest-asym='original:0') and $query-expansion.query-match-type='exact'\">
        <op-exp>
          <xsl:copy-of select=\"@*\" />
          <term field=\"query\" str=\"{term[@implicit-phrase='true']/@str}\" processing=\"strict\" use=\"false\" implicit-phrase=\"true\" />
          <xsl:apply-templates select=\"term[not(@implicit-phrase)]\" mode=\"get-revised-selected\" />
        </op-exp>
      </xsl:when>
      <xsl:otherwise>
        <op-exp>
          <xsl:copy-of select=\"@*\" />
          <xsl:apply-templates select=\"op-exp|operator|term\" mode=\"get-revised-selected\" />
        </op-exp>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>

  <xsl:template match=\"term\" mode=\"get-revised-selected\">
    <xsl:variable name=\"t\" select=\".\" />
    <xsl:variable name=\"orig-term\" select=\"../term[not(@relation)]\" />
    <xsl:choose>
      <xsl:when test=\"$revised='1' and ($used-terms-node=concat($orig-term/@str, '|', $t/@str) or not($t/@relation))\">
        <term>
          <xsl:copy-of select=\"@*\" />
          <xsl:attribute name=\"use\">true</xsl:attribute>
          <xsl:variable name=\"weight-rel\" select=\"$auto-sym[starts-with(., concat($t/@relation, ':'))]|$auto-asym[starts-with(., concat($t/@relation, ':'))]|$suggest-sym[starts-with(., concat($t/@relation, ':'))]|$suggest-asym[starts-with(., concat($t/@relation, ':'))]\" />
          <xsl:if test=\"$weight-rel\">
            <xsl:attribute name=\"weight\">
              <xsl:value-of select=\"substring-after($weight-rel, ':')\" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test=\"contains(@str, ' ') and not(@phrase)\">    
            <xsl:attribute name=\"phrase\">phrase</xsl:attribute>
          </xsl:if>
        </term>
      </xsl:when>
      <xsl:when test=\"$revised='1' and not($used-terms-node=concat($orig-term/@str, '|', $t/@str))\">
        <term>
          <xsl:copy-of select=\"@*\" />
          <xsl:attribute name=\"use\">false</xsl:attribute>
          <xsl:if test=\"contains(@str, ' ') and not(@phrase)\">    
            <xsl:attribute name=\"phrase\">phrase</xsl:attribute>
          </xsl:if>
        </term>
      </xsl:when>
      <xsl:when test=\"not($revised='1') and $query-expansion.user-profile='suggestions-only'\">
          <term>
            <xsl:copy-of select=\"@*\" />
            <xsl:attribute name=\"use\"><xsl:value-of select=\"viv:if-else(@str=$orig-term/@str, 'true', 'false')\" /></xsl:attribute>
            <xsl:if test=\"contains(@str, ' ') and not(@phrase)\">    
              <xsl:attribute name=\"phrase\">phrase</xsl:attribute>
            </xsl:if>
          </term>
      </xsl:when>
      <xsl:when test=\"($auto-sym=$t/@relation or 'stemming'=$t/@relation or $auto-sym[starts-with(., concat($t/@relation, ':'))] or $auto-asym=$t/@relation or $auto-asym[starts-with(., concat($t/@relation, ':'))]) or (not($t/@relation) and not($auto-sym='original:0' or $auto-asym='original:0') or $auto-sym-stem/*=$t/@relation or $auto-asym-stem/*=$t/@relation)\">
          <term>
            <xsl:copy-of select=\"@*\" />
            <xsl:attribute name=\"use\">true</xsl:attribute>
            <xsl:variable name=\"this-rel\" select=\"viv:if-else($t/@relation, $t/@relation, 'original')\" />
            <xsl:variable name=\"weight-rel\" select=\"$auto-sym[starts-with(., concat($this-rel, ':'))]|$auto-asym[starts-with(., concat($this-rel, ':'))]|$suggest-sym[starts-with(., concat($this-rel, ':'))]|$suggest-asym[starts-with(., concat($this-rel, ':'))]\" />
            <xsl:if test=\"$weight-rel\">
              <xsl:attribute name=\"weight\">
                 <xsl:value-of select=\"substring-after($weight-rel, ':')\" />
              </xsl:attribute>
            </xsl:if>
            <xsl:if test=\"contains(@str, ' ') and not(@phrase)\">    
              <xsl:attribute name=\"phrase\">phrase</xsl:attribute>
            </xsl:if>
          </term>
      </xsl:when>
      <xsl:when test=\"not($t/@relation) and ($auto-sym='original:0' or $auto-asym='original:0')\">
        <term>
          <xsl:copy-of select=\"$t/@*\" />
          <xsl:if test=\"count(../term)>1\">
            <xsl:attribute name=\"weight\">0</xsl:attribute>
          </xsl:if>
        </term>
      </xsl:when>
      <xsl:when test=\"$suggest-sym=$t/@relation or $suggest-sym[starts-with(., concat($t/@relation, ':'))] or $suggest-asym=$t/@relation or $suggest-asym[starts-with(., concat($t/@relation, ':'))]  or $suggest-sym-stem/*=$t/@relation or $suggest-asym-stem/*=$t/@relation\">
          <term>
            <xsl:copy-of select=\"@*\" />
            <xsl:attribute name=\"use\">false</xsl:attribute>
            <xsl:if test=\"contains(@str, ' ') and not(@phrase)\">    
              <xsl:attribute name=\"phrase\">phrase</xsl:attribute>
            </xsl:if>
          </term>
      </xsl:when>
      <xsl:otherwise>
        <missed>
          <xsl:copy-of select=\"@*\" />
        </missed>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match=\"query\" mode=\"vxml-format\">
    <query>
      <xsl:apply-templates select=\"*\" mode=\"vxml-format\" />
    </query>
  </xsl:template>

  <xsl:template match=\"op-exp\" mode=\"vxml-format\">
    <operator>
      <xsl:copy-of select=\"@*\" />
      <xsl:apply-templates select=\"*\" mode=\"vxml-format\" />
      <xsl:if test=\"name(..)='query'\">
        <xsl:variable name=\"qn\" select=\"exsl:node-set($query-now)\" />
        <xsl:if test=\"$qn//term[@field='binningstate' or @field='v.binning-state']\">
          <xsl:copy-of select=\"$qn//term[@field='binningstate' or @field='v.binning-state']\" />
        </xsl:if>
      </xsl:if>
    </operator>
  </xsl:template>


  <xsl:template match=\"term[@use='false' or @weight='0' or @field='binningstate' or @field='v.binning-state']\" mode=\"vxml-format\" />

  <xsl:template match=\"term\" mode=\"vxml-format\">
    <term>
      <xsl:copy-of select=\"@*[not(name(.)='relation') and not(name(.)='use')]\" />
    </term>
  </xsl:template>

  <xsl:template match=\"op-exp\" mode=\"exact-terms-set-false\">
    <op-exp>
      <xsl:copy-of select=\"@*\" />
      <xsl:apply-templates select=\"op-exp\" mode=\"exact-terms-set-false\" />
      <xsl:choose>
        <xsl:when test=\"./term[@implicit-phrase] and (count(./term) > 1)\">
           <xsl:copy-of select=\"term\" />
        </xsl:when> 
        <xsl:otherwise>
          <xsl:copy-of select=\"term[not(@relation)]\" />
          <xsl:apply-templates select=\"term[@relation]\" mode=\"exact-terms-set-false\" />
        </xsl:otherwise>
      </xsl:choose>
    </op-exp>
  </xsl:template>

  <xsl:template match=\"term\" mode=\"exact-terms-set-false\">
    <term>
      <xsl:copy-of select=\"@*[not(name(.)='use')]\" />
      <xsl:attribute name=\"use\">false</xsl:attribute>
      <xsl:if test=\"contains(@str, ' ') and not(@phrase)\">    
        <xsl:attribute name=\"phrase\">phrase</xsl:attribute>
       </xsl:if>
    </term>
  </xsl:template>

  <xsl:template match=\"op-exp\" mode=\"stemming-expansion\">
    <op-exp>
      <xsl:copy-of select=\"@*\" />
      <xsl:apply-templates select=\"op-exp\" mode=\"stemming-expansion\" />
      <xsl:apply-templates select=\"term[not(@relation)]\" mode=\"stemming-expansion-original\"/>
      <xsl:apply-templates select=\"term[@relation]\" mode=\"stemming-expansion-others\" />
    </op-exp>
  </xsl:template>

  <xsl:template match=\"term\" mode=\"stemming-expansion-original\">
    <xsl:variable name=\"original\" select=\"@str\" />
    <term>
      <xsl:copy-of select=\"@*\" />
    </term> 

    <xsl:variable name=\"rel-path\" select=\"viv:value-of('query-expansion.stemming-dictionary', 'var')\" />

    <xsl:variable name=\"stem-dict-path\" select=\"viv:if-else(starts-with($rel-path, '/') or viv:test($rel-path, '[a-z]:\\', 'case-insensitive-regex'), $rel-path, 
concat(viv:value-of('install-dir', 'option'), '/data/dictionaries/', $rel-path))\" />

    <xsl:variable name=\"stemming-variations\" select=\"viv:unstem(@str, 'query', viv:value-of('meta.stem-expand-stemmer','option'), $stem-dict-path, $query-expansion.max-terms-per-type)\" />
    <xsl:for-each select=\"exsl:node-set($stemming-variations)/term[viv:stem-kb-key(@str, 'depluralize', 'none') != viv:stem-kb-key($original, 'depluralize', 'none')]\">
       <term>
           <xsl:copy-of select=\"@*[not(name(.)='count')]\" />
           <xsl:attribute name=\"relation\">stemming</xsl:attribute>
           <xsl:attribute name=\"word\"><xsl:value-of select=\"$original\"/></xsl:attribute>
       </term>
    </xsl:for-each> 
  </xsl:template>

  <xsl:template match=\"term\" mode=\"stemming-expansion-others\">
    <xsl:variable name=\"expansion\" select=\"@str\" />
    <xsl:variable name=\"rel\" select=\"concat(@relation, '+stemming')\" />
    <term>
      <xsl:copy-of select=\"@*\" />
    </term>
    <xsl:variable name=\"stemming-variations\" select=\"viv:unstem(@str, 'query', viv:value-of('meta.stem-expand-stemmer','option'), viv:value-of('dictionary','option'), $query-expansion.max-terms-per-type)\"/>

    <xsl:for-each select=\"exsl:node-set($stemming-variations)/term[viv:stem-kb-key(@str, 'depluralize', 'none') != viv:stem-kb-key($expansion, 'depluralize', 'none')]\">
       <term>
           <xsl:copy-of select=\"@*[not(name(.)='count')]\" />
           <xsl:attribute name=\"relation\"><xsl:value-of select=\"$rel\" /></xsl:attribute>
           <xsl:attribute name=\"word\"><xsl:value-of select=\"$expansion\"/></xsl:attribute>
       </term>
    </xsl:for-each> 
  </xsl:template>
]]></process-xsl>
</function>"

  vlog "Adding query-expand and display api function to repository"
  @vapi.repository_add( :node => query_expand ) 
  @vapi.repository_add( :node => expand_query_selected_terms_api ) 
end

def log_query(q, mq = nil)
  vlog "original query:\n #{q}"
  vlog "modified query:\n #{mq}" unless mq.nil?
end
