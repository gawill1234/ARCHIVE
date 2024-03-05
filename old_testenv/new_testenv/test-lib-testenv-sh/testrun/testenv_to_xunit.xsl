<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"> 
  <xsl:param name='build_url'/>
  <xsl:param name='job_name'/>

  <xsl:output omit-xml-declaration = "yes"/> 
 
  <xsl:template match='/'>
    <testsuites>
      <xsl:apply-templates select='results'/>
    </testsuites>
  </xsl:template>

  <xsl:template match='results'>

    <xsl:element name='testsuite'>
      <xsl:attribute name='id'>
        <xsl:value-of select='pid'/>
      </xsl:attribute>
      <xsl:attribute name='name'>
        <xsl:value-of select='name'/>
      </xsl:attribute>
      <xsl:attribute name='timestamp'>
        <xsl:value-of select='sdate'/>.<xsl:value-of select='stime'/>
      </xsl:attribute>
      <xsl:attribute name='hostname'>
        <xsl:value-of select='host'/>
      </xsl:attribute>
      <xsl:attribute name='tests'>
        <xsl:value-of select='count(test)'/>
      </xsl:attribute>
      <xsl:attribute name='failures'>
        <xsl:value-of select='count(test[result/text()="Test Failed"])'/>
      </xsl:attribute>
      <xsl:attribute name='errors'>
        <xsl:value-of select='count(test[result/text()="Test Errors"])'/>
      </xsl:attribute>
      <xsl:attribute name='skipped'>
        <xsl:value-of select='count(test[result/text()="Test Skipped"])'/>
      </xsl:attribute>
      <xsl:attribute name='time'>
        <xsl:value-of select='etime - stime'/>
      </xsl:attribute>
      <xsl:apply-templates select='test'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="test">
    <xsl:element name='testcase'>
      <xsl:attribute name='name'>
        <xsl:value-of select='name'/>
      </xsl:attribute>
      <xsl:attribute name='classname'>
        <xsl:value-of select='name'/>
      </xsl:attribute>
      <xsl:attribute name='time'>
        <xsl:value-of select='etime - stime'/>
      </xsl:attribute>
      <xsl:apply-templates select='result'>
        <xsl:with-param name='stderr_url'>
          <xsl:value-of select='concat($build_url, "/artifact", substring-after( loc, $job_name ), "/", name, ".stderr")'/>
        </xsl:with-param>
        <xsl:with-param name='stdout_url'>
          <xsl:value-of select='concat($build_url, "/artifact", substring-after( loc, $job_name ), "/", name, ".stdout")'/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
	
  <xsl:template match='result[text() = "Test Passed"]'>
    <xsl:param name='stderr_url'/>
    <xsl:param name='stdout_url'/>
  </xsl:template>

  <xsl:template match='result[text() = "Test Failed"]'>
    <xsl:param name='stderr_url'/>
    <xsl:param name='stdout_url'/>
    <failure>
      <a href='{$stdout_url}'>STDOUT</a> <a href='${stderr_url}'>STDERR</a>
    </failure>
  </xsl:template>

  <xsl:template match='result[text() = "Test Error"]'>
    <error>
      <a href='${stdout_url}'>STDOUT</a> <a href='${stderr_url}'>STDERR</a>
    </error>
  </xsl:template>

  <xsl:template match='result[text() = "Test Skipped"]'>
    <skipped/>
  </xsl:template>

</xsl:stylesheet>

