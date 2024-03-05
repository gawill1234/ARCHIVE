def query_node_to_string_test_setup
    begin
      func = <<HERE
<function name="query-node-to-string-test" type="public-api">
  <prototype>
    <declare name="query" type="nodeset" required="required" />
    <declare name="include-operators" initial-value="true" type="boolean" />
    <declare name="include-parentheses" initial-value="true" type="boolean" />
  </prototype>
  <process-xsl><![CDATA[
    <xsl:param name="query" />
    <xsl:param name="include-operators" />
    <xsl:param name="include-parentheses" />
    <xsl:template match="/">
      <xsl:variable name="call-func">
          <call-function name="query-node-to-string">
            <with name="query" process=""><xsl:copy-of select="$query" /></with>
            <with name="include-operators"><xsl:value-of select="$include-operators" /></with>
            <with name="include-parentheses"><xsl:value-of select="$include-parentheses" /></with>
          </call-function>
      </xsl:variable>
      <xsl:variable name="call-func-results" select="viv:process-xml($call-func)" />
      <top process="">
        <copy><xsl:copy-of select="$call-func-results/span" /></copy>
        <value><xsl:value-of select="$call-func-results" /></value>
      </top>
    </xsl:template>
  ]]></process-xsl>
</function>
HERE
      @vapi.repository_add(:node => func)
    rescue
      #already exists, this is fine
    end
end