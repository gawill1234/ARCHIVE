<application name="japdap">
   <call-function name="util-print-http-headers"/>
   <declare name="username" initial-value="CN=Administrator,CN=Users,DC=vivisimo2003,DC=vmserver,DC=vivisimo,DC=com" process=""/>
   <declare name="password" initial-value="{vcrypt}Dc9TQ1nYURBkDl+YZmvRKA==" process=""/>
   <declare name="url" initial-value="ldap://192.168.0.27:389/cn=技術部,cn=Users,DC=vivisimo2003,DC=vmserver,DC=vivisimo,DC=com?*" process=""/>
   <declare name="ldap-xml" type="nodeset"/>

   <set-var name="ldap-xml">

      <parse username="{$username}" password="{$password}" url="{$url}" encoding="utf-8">
         <parser type="html-xsl">
            <xml-to-text>
               <xsl:template match="/">
                  <ldap>
                     <xsl:for-each select="str:tokenize(., '&#10;')">
                        <part>
                           <xsl:attribute name="name">
                              <xsl:value-of select="normalize-space(substring-before(., ':'))"/>
                           </xsl:attribute>
                           <xsl:value-of select="substring-after(., ':')"/>
                        </part>
                     </xsl:for-each>
                  </ldap>
               </xsl:template>
            </xml-to-text>
         </parser>
      </parse>
   </set-var>

   <fetch finish="finish" timeout="30000"/>

   <print>
      <process-xsl encode="encode">
         <xml-to-text>
            <xsl:output method="text"/>
            <xsl:param name="ldap-xml"/>
            <xsl:template match="/">
               <xsl:choose>
                  <xsl:when test="not($ldap-xml)">
                     <xsl:text>failure</xsl:text>
                     <xsl:text>
                     </xsl:text>
                     <xsl:text>No result was returned from the LDAP server</xsl:text>
                  </xsl:when>
                  <xsl:when test="normalize-space($ldap-xml//part[@name='cn']) = '技術部'">
                     <xsl:text>success</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>failure</xsl:text>
                     <xsl:text>
                     </xsl:text>
                     <xsl:text>Did not pass test</xsl:text>
                     <xsl:value-of select="viv:node-to-str($ldap-xml)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:template>
         </xml-to-text>
      </process-xsl>
   </print>

   <catch as="e">
      <print>
         <scope>failure
            An exception occurred
         </scope>

         <xml-to-text process="*" pretty="pretty">
            <copy-of select="$e"/>
         </xml-to-text>
      </print>
   </catch>

</application>
