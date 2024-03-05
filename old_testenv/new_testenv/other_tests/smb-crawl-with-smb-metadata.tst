#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'misc'
require 'collection'
require 'nokogiri'

def set_queries(os_being_tested)

   if ( os_being_tested == "Windows" )
      #
      #   The queries include the standard queries for a crawl of this data PLUS
      #   some queries of data that will only be there if the metadata was correctly
      #   grabbed and indexed by the crawl.  "Administrator" is specific to windows.
      #   "root" is specific to linux.  "2010" is specific to testbed8.  "2007" is
      #   specific to testbed5.  If these machines change and the dates of the files
      #   change, the queries will have to updated.  The "2009" is in the text and is
      #   added to have a query of year that is different than that for the metadata.
      #
      queries = {"Hamilton"         => 5,
                 "Hamilton Madison" => 5,
                 "Linux"            => 6,
                 "QueryThatWillNotMatchAnyDocuments"     => 0,
                 "Administrator"     => 47,
                 "2009"     => 2,
                 "2010"     => 47,
                 "We the people"    => 19}
   else  #  os_being_tested == "Linux"
      queries = {"Hamilton"         => 5,
                 "Hamilton Madison" => 5,
                 "Linux"            => 6,
                 "QueryThatWillNotMatchAnyDocuments"     => 0,
                 "root"     => 47,
                 "2009"     => 2,
                 "2007"     => 47,
                 "We the people"    => 19}
   end

   return queries

end


###################################
#
#   Crawl configurations
#
crawler_configs = {<<"WINXML" => "Windows", <<"LINUXXML" => "Linux"
     <crawl-options>
       <crawl-option name="n-fetch-threads">10</crawl-option>
       <curl-option name="filter-exact-duplicates"><![CDATA[false]]></curl-option>
       <curl-option name="converter-max-memory">512</curl-option>
     </crawl-options>
     <call-function name="vse-crawler-seed-smb">
       <with name="host"><![CDATA[testbed8.bigdatalab.ibm.com]]></with>
       <with name="shares"><![CDATA[/exported/samba_test_data/samba-1/doc]]></with>
       <with name="username"><![CDATA[administrator]]></with>
       <with name="password"><![CDATA[{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==]]></with>
       <with name="crawl-fs-metadata">true</with>
     </call-function>
WINXML
     <crawl-options>
       <crawl-option name="n-fetch-threads">10</crawl-option>
       <curl-option name="filter-exact-duplicates"><![CDATA[false]]></curl-option>
       <curl-option name="converter-max-memory">512</curl-option>
     </crawl-options>
     <call-function name="vse-crawler-seed-smb">
       <with name="host"><![CDATA[testbed5.bigdatalab.ibm.com]]></with>
       <with name="shares"><![CDATA[/testfiles/samba_test_data/samba-1/doc]]></with>
       <with name="username"><![CDATA[root]]></with>
       <with name="password"><![CDATA[{vcrypt}TMWiymi8UsQ9QvtqWkxuhw==]]></with>
       <with name="crawl-fs-metadata">true</with>
     </call-function>
LINUXXML
}

#
###################################

test_results = TestResults.new("Samba crawl of samba data AND metadata for both windows and linux")

collection = Collection.new(TESTENV.test_name)
test_results.associate(collection)

crawler_configs.each do | crawler_config, os_being_tested |

   queries = set_queries(os_being_tested)
   print "\nUSING THIS CONFIG FOR THIS CRAWL OF ", os_being_tested, " Samba/CIFS\n\n"
   print crawler_config, "\n\n"

   collection.delete
   collection.create("default")

   xml = collection.xml
   xml.xpath("/vse-collection/vse-config/crawler").children.before(crawler_config)
   collection.set_xml(xml)

   msg "Starting crawl"
   collection.clean
   collection.crawler_start
   collection.wait_until_crawler_stopped
   msg "Crawl finished"

   queries.each do | query, expected |
      source_xpath = "/query-results/added-source"
      result = collection.search(query, {:output_duplicates => true})
      n_returned = result.xpath(source_xpath).first['total-results'].to_i
      test_results.add_number_equals(expected, n_returned, "'#{query}' result")
   end
end

test_results.cleanup_and_exit!
