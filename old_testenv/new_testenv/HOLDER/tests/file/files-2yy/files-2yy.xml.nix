<?xml version="1.0"?>
<vse-collection name="files-2yy" modified="1214489359">
  <vse-config elt-id="2026" max-elt-id="2130">
    <crawler elt-id="2027">
      <call-function elt-id="2129" type="crawl-seed" name="vse-crawler-seed-files">
        <with name="files" elt-id="2130">/testenv/test_data/law/US/544</with>
      </call-function>
      <call-function name="vse-crawler-exact-duplicates-for-http" elt-id="2028"/>
      <call-function name="vse-crawler-binary-file-extensions" elt-id="2029"/>
      <call-function name="vse-crawler-no-delay-for-files" elt-id="2030"/>
      <call-function name="vse-crawler-session-ids" elt-id="2031"/>
      <call-function name="vse-crawler-apache-directory-browsing" elt-id="2032"/>
      <call-function name="vse-crawler-bugzilla" elt-id="2033"/>
      <call-function name="vse-crawler-calendars-forums" elt-id="2034"/>
      <call-function name="vse-crawler-lotus-domino-site" elt-id="2035"/>
      <call-function name="vse-crawler-verity-query-service" elt-id="2036"/>
      <call-function name="vse-crawler-wiki" elt-id="2037"/>
    </crawler>
    <vse-index elt-id="2038"/>
    <converters elt-id="2039">
      <converter type-in="vivisimo/fallback" type-out="application/vxml-unnormalized" elt-id="2040">
        <call-function name="vse-converter-unknown-to-vxml" elt-id="2041">
          <with name="extract-strings" elt-id="2042">no, output XML</with>
        </call-function>
      </converter>
      <converter type-in="unknown" type-out="dead" elt-id="2043">
        <call-function name="vse-converter-binary-files-in-archives" elt-id="2044"/>
      </converter>
      <converter type-in="unknown" program="guess-content %source_file" timing-name="Guess content" elt-id="2045"/>
      <converter type-in="application/ms-office" program="ms-guess %source_file" timing-name="Guess MS Office" elt-id="2046"/>
      <converter type-in="application/ms-office-container" program="unzip -l %source_file | ms-container-guess" timing-name="Guess MS Office 2007" elt-id="2047"/>
      <converter type-in="unknown" type-out="text/plain" elt-id="2048">
        <converter-test how="wc-set" what="path" elt-id="2049">*.txt</converter-test>
      </converter>
      <converter type-in="unknown" type-out="application/excel" elt-id="2050">
        <converter-test how="wc-set" what="path" elt-id="2051">*.xls</converter-test>
      </converter>
      <call-function name="vse-converter-filetypes" elt-id="2052"/>
      <call-function name="vse-converter-type-normalization" elt-id="2053"/>
      <converter type-in="application/vxml-db" type-out="application/vxml-unnormalized" elt-id="2054">
        <call-function name="vse-converter-database-tng" elt-id="2055"/>
      </converter>
      <call-function name="vse-converter-powerpoint" elt-id="2056"/>
      <call-function name="vse-converter-1-2-3" elt-id="2057"/>
      <converter type-in="outlook/mail" type-out="application/outlook-msg" fallback="outlook/mail" min-max-elapsed="3600" min-max-cpu="3600" min-max-memory="2000" elt-id="2058">
        <call-function name="vse-converter-pst-2003-to-msg" elt-id="2059"/>
      </converter>
      <converter type-in="outlook/mail" type-out="text/mailbox" elt-id="2060">
        <call-function name="vse-converter-pst-to-mailbox" elt-id="2061"/>
      </converter>
      <converter type-in="text/mailbox" type-out="text/mail" elt-id="2062">
        <call-function name="vse-converter-split-mailbox" elt-id="2063"/>
      </converter>
      <converter type-in="text/mail" type-out="vivisimo/crawl-data" elt-id="2064">
        <call-function name="vse-converter-mail-message" elt-id="2065">
          <with name="cache-parser" elt-id="2066">vse-cache-parser-email</with>
        </call-function>
      </converter>
      <converter type-in="application/documentum" type-out="application/vxml-unnormalized" elt-id="2067">
        <call-function name="vse-converter-documentum-to-xml" elt-id="2068"/>
      </converter>
      <call-function name="vse-converter-enterprise-vault" elt-id="2069"/>
      <converter type-in="application/eroom" type-out="application/vxml-unnormalized" elt-id="2070">
        <call-function name="vse-converter-eroom-to-xml" elt-id="2071"/>
      </converter>
      <converter type-out="application/vxml-unnormalized" type-in="application/lotus" elt-id="2072">
        <call-function name="vse-converter-lotus-to-xml" elt-id="2073"/>
      </converter>
      <converter type-in="application/sharepoint" type-out="application/vxml-unnormalized" elt-id="2074">
        <call-function name="vse-converter-sharepoint-to-xml" elt-id="2075"/>
      </converter>
      <converter type-in="application/word" type-out="text/html" elt-id="2076">
        <call-function name="vse-converter-msword" elt-id="2077"/>
      </converter>
      <converter type-in="application/excel" type-out="text/html" elt-id="2078">
        <call-function name="vse-converter-excel" elt-id="2079"/>
      </converter>
      <converter type-in="application/wordperfect" type-out="text/html" elt-id="2080">
        <call-function name="vse-converter-wordperfect" elt-id="2081"/>
      </converter>
      <converter type-in="application/openoffice" type-out="text/html" elt-id="2082">
        <call-function name="vse-converter-openoffice" elt-id="2083"/>
      </converter>
      <converter type-in="application/ms-ooxml-word" type-out="text/html" elt-id="2084">
        <call-function name="vse-converter-ooxml-word" elt-id="2085"/>
      </converter>
      <converter type-in="application/ms-ooxml-excel" type-out="text/html" elt-id="2086">
        <call-function name="vse-converter-ooxml-excel" elt-id="2087"/>
      </converter>
      <converter type-in="application/ms-ooxml-powerpoint" type-out="text/html" elt-id="2088">
        <call-function name="vse-converter-ooxml-powerpoint" elt-id="2089"/>
      </converter>
      <converter type-in="application/vnd.ms-project" type-out="application/vxml-unnormalized" elt-id="2090">
        <call-function name="vse-converter-ms-project" elt-id="2091"/>
      </converter>
      <converter type-in="application/ps" type-out="text/plain" elt-id="2092">
        <call-function name="vse-converter-postscript" elt-id="2093"/>
      </converter>
      <converter type-in="application/pdf" type-out="text/html" elt-id="2094">
        <call-function name="vse-converter-pdf" elt-id="2095"/>
      </converter>
      <converter type-in="application/rtf" type-out="text/html" elt-id="2096">
        <call-function name="vse-converter-rtf" elt-id="2097"/>
      </converter>
      <converter type-in="application/outlook-msg" type-out="vivisimo/crawl-data" elt-id="2098">
        <call-function name="vse-converter-outlook-msg" elt-id="2099"/>
      </converter>
      <converter type-in="application/flash" type-out="text/html" elt-id="2100">
        <call-function name="vse-converter-flash" elt-id="2101"/>
      </converter>
      <converter type-out="application/vxml-unnormalized" type-in="image/jpeg" elt-id="2102">
        <call-function name="vse-converter-jpg-metadata" elt-id="2103"/>
      </converter>
      <converter timing-name="MP3 to metadata" type-in="audio/mpeg" type-out="application/vxml-unnormalized" elt-id="2104">
        <call-function name="vse-converter-mp3-metadata" elt-id="2105"/>
      </converter>
      <converter type-in="application/tar" type-out="unknown" elt-id="2106">
        <call-function name="vse-converter-tar" elt-id="2107"/>
      </converter>
      <converter type-in="application/x-gzip" type-out="unknown" elt-id="2108">
        <call-function name="vse-converter-gunzip" elt-id="2109"/>
      </converter>
      <converter type-in="application/zip" type-out="unknown" elt-id="2110">
        <call-function name="vse-converter-unzip" elt-id="2111"/>
      </converter>
      <converter type-in="application/x-compress" type-out="unknown" elt-id="2112">
        <call-function name="vse-converter-uncompress" elt-id="2113"/>
      </converter>
      <converter type-in="text/html" type-out="application/vxml-unnormalized" elt-id="2114">
        <call-function name="vse-converter-html" elt-id="2115"/>
      </converter>
      <converter type-in="text/plain" type-out="application/vxml-unnormalized" elt-id="2116">
        <call-function name="vse-converter-text" elt-id="2117"/>
      </converter>
      <converter type-in="unknown" type-out="application/dbf" elt-id="2118">
        <converter-test how="wc-set" what="path" elt-id="2119">*.dbf</converter-test>
      </converter>
      <converter type-in="application/dbf" type-out="text/csv" elt-id="2120">
        <call-function name="vse-converter-dbf-to-csv" elt-id="2121"/>
      </converter>
      <converter type-in="text/csv" type-out="text/html" elt-id="2122">
        <call-function name="vse-converter-csv-to-html" elt-id="2123"/>
      </converter>
      <converter type-in="text/xml" type-out="application/vxml-unnormalized" elt-id="2124">
        <call-function name="vse-converter-xml-to-vxml" elt-id="2125"/>
      </converter>
      <converter type-in="application/vxml-unnormalized" type-out="application/vxml-unnormalized" fallback="application/vxml" elt-id="2126">
        <call-function name="vse-converter-normalize" elt-id="2127"/>
      </converter>
      <converter type-in="application/vxml-unnormalized" type-out="application/vxml" elt-id="2128"/>
    </converters>
  </vse-config>
  <vse-meta name="files-2yy" creator="gary_testing" create-time="1214489317" elt-id="1" max-elt-id="1"/>
</vse-collection>
