$LOAD_PATH << ENV['RUBYLIB']
require 'loader'

# xpath_helper.rb
#
# The doc_count and url methods are used to detect the pass/fail
# status of each test.

def collection_xml
  xml = <<HERE
<vse-collection modified="1260465080" name="xpath-operator-testing" modified-by="test-all" max-elt-id="125">
  <vse-config max-elt-id="123">
    <crawler>
      <call-function name="vse-crawler-seed-urls" type="crawl-seed">
        <with name="urls">http://vivisimo.com</with>
        <with name="hops">0</with>
      </call-function>
      <call-function name="vse-crawler-exact-duplicates-for-http" />
      <call-function name="vse-crawler-binary-file-extensions" />
      <call-function name="vse-crawler-no-delay-for-files" />
      <call-function name="vse-crawler-session-ids" />
      <call-function name="vse-crawler-apache-directory-browsing" />
      <call-function name="vse-crawler-bugzilla" />
      <call-function name="vse-crawler-calendars-forums" />
      <call-function name="vse-crawler-lotus-domino-site" />
      <call-function name="vse-crawler-verity-query-service" />
      <call-function name="vse-crawler-wiki" />
    </crawler>
    <vse-index>
      <vse-index-streams>
        <call-function name="vse-index-streams-common">
          <with name="stem">depluralize</with>
        </call-function>
      </vse-index-streams>
    </vse-index>
    <converters>
      <converter timing-name="create documents for xpath testing" type-in="text/html" type-out="application/vxml">
        <parser type="html-xsl"><![CDATA[<xsl:template match="*">
  <scope>
    <!-- simple numbers from -2 to +2 in steps of .5, fast-indexed as numbers -->
    <document url="simple-number-2">
      <content fast-index="number" name="simple-number"><![CDATA[-2]]]><![CDATA[]></content>
      <content name="snippet"><![CDATA[Here is some snippet from the -2 document]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-1.5">
      <content fast-index="number" name="simple-number"><![CDATA[-1.5]]]><![CDATA[]></content>
      <content name="snippet"><![CDATA[Here is some snippet from the -1.5 document]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-1">
      <content fast-index="number" name="simple-number"><![CDATA[-1]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-.5">
      <content fast-index="number" name="simple-number"><![CDATA[-.5]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-0">
      <content fast-index="number" name="simple-number"><![CDATA[0]]]><![CDATA[]></content>
      <content name="snippet"><![CDATA[Here is some snippet from the 0 document]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-+.5">
      <content fast-index="number" name="simple-number"><![CDATA[.5]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-+1">
      <content fast-index="number" name="simple-number"><![CDATA[1]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-+1.5">
      <content fast-index="number" name="simple-number"><![CDATA[1.5]]]><![CDATA[]></content>
    </document>
    <document url="simple-number-+2">
      <content fast-index="number" name="simple-number"><![CDATA[2]]]><![CDATA[]></content>
      <content name="snippet"><![CDATA[Here is some snippet from the 2 document]]]><![CDATA[]></content>
    </document>

    <!-- a number indexed as a string instead -->
    <document url="not-simple-number">
      <content fast-index="set" name="simple-number"><![CDATA[1]]]><![CDATA[]></content>
    </document>

    <!-- one number indexed as a number, the same number indexed as a string -->
    <document url="simple-mix">
      <content fast-index="number" name="simple-number"><![CDATA[4]]]><![CDATA[]></content>
      <content fast-index="set" name="simple-number"><![CDATA[4]]]><![CDATA[]></content>
    </document>

    <!-- contents with acls on them -->
    <document url="simple-number-rights">
      <content fast-index="checked-number" name="simple-number" acl="+test-user"><![CDATA[5]]]><![CDATA[]></content>
      <content fast-index="checked-number" name="simple-number" acl="+test-user2"><![CDATA[6]]]><![CDATA[]></content>
      <content fast-index="number" name="simple-number"><![CDATA[7]]]><![CDATA[]></content>
    </document>

    <!-- the greek alphabet -->
    <xsl:for-each select="str:tokenize('Alpha Beta Gamma Delta Epsilon Zeta Eta Theta Iota Kappa Lambda Mu Nu Xi Omicron Pi Rho Sigma Tau Upsilon Phi Omega')">
      <document url="{.}">
        <content fast-index="set" name="simple-string">
          <xsl:value-of select="." />
        </content>
      </document>
    </xsl:for-each>

    <!-- dates including ranges over: leap years, new years, months, days, seconds -->
    <xsl:for-each select="str:tokenize('2000/02/28,2000/02/29,2000/03/01,2001/12/31,2002/01/01,2003-09-12 20:49:36,2004-10-12 20:49:37,2005-11-12 20:49:38,2006-09-12 20:49:36,2006-10-12 20:49:37,2006-11-12 20:49:38,2007-10-10 20:49:36,2007-10-11 20:49:37,2007-10-12 20:49:38,2008-10-12 20:49:36,2008-10-12 20:49:37,2008-10-12 20:49:38', ',')">
      <document url="simple-date-good-{viv:replace(., ' ', '', 'g')}">
        <content name="simple-date" fast-index="date">
          <xsl:value-of select="." />
        </content>
      </document>
    </xsl:for-each>

    <!-- a document with two dates in -->
    <document url="simple-dates">
      <content name="simple-date" fast-index="date"><![CDATA[2008-10-12 20:49:35]]]><![CDATA[]></content>
      <content name="simple-date" fast-index="date"><![CDATA[2008-10-12 20:49:39]]]><![CDATA[]></content>
    </document>
  </scope>
</xsl:template>
]]></parser>
      </converter>
      <converter type-in="vivisimo/fallback" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-unknown-to-vxml">
          <with name="extract-strings">no, output XML</with>
        </call-function>
      </converter>
      <converter type-in="unknown" type-out="dead">
        <call-function name="vse-converter-binary-files-in-archives" />
      </converter>
      <converter type-in="unknown" program="guess-content --type-override text/html text/html-to-utf8 %source_file" timing-name="Guess content" />
      <converter type-in="application/ms-office" program="ms-guess %source_file" timing-name="Guess MS Office" />
      <converter type-in="application/ms-office-container" program="unzip -l %source_file | ms-container-guess" timing-name="Guess MS Office 2007" />
      <converter type-in="application/word|application/excel|application/powerpoint" program="guess-office-2007 %source_file" timing-name="Check MS Office version" />
      <converter type-in="unknown" type-out="text/plain">
        <converter-test how="wc-set" what="path">*.txt</converter-test>
      </converter>
      <converter type-in="unknown" type-out="application/excel">
        <converter-test how="wc-set" what="path">*.xls</converter-test>
      </converter>
      <call-function name="vse-converter-filetypes" />
      <call-function name="vse-converter-type-normalization" />
      <converter type-in="application/vxml-db" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-database-tng" />
      </converter>
      <call-function name="vse-converter-powerpoint" />
      <call-function name="vse-converter-1-2-3" />
      <converter type-in="outlook/mail" type-out="text/mailbox">
        <call-function name="vse-converter-pst-to-mailbox" />
      </converter>
      <converter type-in="text/mailbox" type-out="text/mail">
        <call-function name="vse-converter-split-mailbox" />
      </converter>
      <converter type-in="text/mail" type-out="vivisimo/crawl-data">
        <call-function name="vse-converter-mail-message">
          <with name="cache-parser">vse-cache-parser-email</with>
        </call-function>
      </converter>
      <converter type-in="application/documentum" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-documentum-to-xml" />
      </converter>
      <call-function name="vse-converter-enterprise-vault" />
      <converter type-in="application/eroom" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-eroom-to-xml" />
      </converter>
      <converter type-out="application/vxml-unnormalized" type-in="application/lotus">
        <call-function name="vse-converter-lotus-to-xml" />
      </converter>
      <converter type-in="application/sharepoint" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-sharepoint-to-xml" />
      </converter>
      <converter type-in="application/word2" type-out="text/html">
        <call-function name="vse-converter-msword2" />
      </converter>
      <converter type-in="application/word" type-out="text/html">
        <call-function name="vse-converter-msword" />
      </converter>
      <converter type-in="application/excel" type-out="text/html">
        <call-function name="vse-converter-excel" />
      </converter>
      <converter type-in="application/wordperfect" type-out="text/html">
        <call-function name="vse-converter-wordperfect" />
      </converter>
      <converter type-in="application/openoffice" type-out="text/html">
        <call-function name="vse-converter-openoffice" />
      </converter>
      <converter type-in="application/ms-ooxml-word" type-out="text/html">
        <call-function name="vse-converter-ooxml-word" />
      </converter>
      <converter type-in="application/ms-ooxml-excel" type-out="text/html">
        <call-function name="vse-converter-ooxml-excel" />
      </converter>
      <converter type-in="application/ms-ooxml-powerpoint" type-out="text/html">
        <call-function name="vse-converter-ooxml-powerpoint" />
      </converter>
      <converter type-in="application/vnd.ms-project" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-ms-project" />
      </converter>
      <converter type-in="application/ps" type-out="text/plain">
        <call-function name="vse-converter-postscript" />
      </converter>
      <converter type-in="application/pdf" type-out="text/html">
        <call-function name="vse-converter-pdf" />
      </converter>
      <converter type-in="application/rtf" type-out="text/html">
        <call-function name="vse-converter-rtf" />
      </converter>
      <converter type-in="application/outlook-msg" type-out="vivisimo/crawl-data">
        <call-function name="vse-converter-outlook-msg" />
      </converter>
      <converter type-in="application/flash" type-out="text/html">
        <call-function name="vse-converter-flash" />
      </converter>
      <converter type-out="application/vxml-unnormalized" type-in="image/jpeg">
        <call-function name="vse-converter-jpg-metadata" />
      </converter>
      <converter timing-name="MP3 to metadata" type-in="audio/mpeg" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-mp3-metadata" />
      </converter>
      <converter type-in="application/tar" type-out="unknown">
        <call-function name="vse-converter-tar" />
      </converter>
      <converter type-in="application/x-gzip" type-out="unknown">
        <call-function name="vse-converter-gunzip" />
      </converter>
      <converter type-in="application/zip" type-out="unknown">
        <call-function name="vse-converter-unzip" />
      </converter>
      <converter type-in="application/x-compress" type-out="unknown">
        <call-function name="vse-converter-uncompress" />
      </converter>
      <converter type-in="text/html-to-utf8" type-out="text/html">
        <call-function name="vse-converter-html-to-utf8" />
      </converter>
      <converter type-in="text/html" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-html" />
      </converter>
      <converter type-in="text/plain" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-text" />
      </converter>
      <converter type-in="unknown" type-out="application/dbf">
        <converter-test how="wc-set" what="path">*.dbf</converter-test>
      </converter>
      <converter type-in="application/dbf" type-out="text/csv">
        <call-function name="vse-converter-dbf-to-csv" />
      </converter>
      <converter type-in="text/csv" type-out="text/html">
        <call-function name="vse-converter-csv-to-html" />
      </converter>
      <converter type-in="text/xml" type-out="application/vxml-unnormalized">
        <call-function name="vse-converter-xml-to-vxml" />
      </converter>
      <converter type-in="application/vxml-unnormalized" type-out="application/vxml-unnormalized" fallback="application/vxml">
        <call-function name="vse-converter-normalize" />
      </converter>
      <converter type-in="application/vxml-unnormalized" type-out="application/vxml" />
    </converters>
  </vse-config>
  <vse-meta name="xpath-operator-testing" />
</vse-collection>
HERE
end

def create_jeans_collection
  c = Collection.new(@vapi, 'xpath-operator-testing')
  c.create rescue return
  config = Nokogiri::XML(collection_xml)
  c.set_config(config)
  c.start_crawl
end

def create_metadata_collection

  c = Collection.new(@vapi, 'test-xpath-operator2')
  c.create('example-metadata') rescue return

  curr_xml = c.get_config
  index_options = <<HERE
<vse-index-option name="term-expand-dicts">true</vse-index-option>
<vse-index-option name="term-expand-dicts-dir">expansions</vse-index-option>
HERE

  opt = Nokogiri::XML(index_options)
  curr_xml.xpath("/vse-collection/vse-config/vse-index").first.add_child opt.root
  c.set_config(curr_xml)
  c.start_crawl

end

def total_results_with_duplicates(xml)
  trwd = xml.xpath('/query-results/added-source/@total-results-with-duplicates')
  sum = 0
  trwd.each {|node| sum += node.to_s.to_i}
  sum
end

def doc_count(xml)
  xml.xpath("//document").length
  # Returns count of documents
end

def url(xml)
  xml.xpath("//document/@url").to_s
  # Returns @url of the first document
end

connect_to_velocity
create_jeans_collection
create_metadata_collection
