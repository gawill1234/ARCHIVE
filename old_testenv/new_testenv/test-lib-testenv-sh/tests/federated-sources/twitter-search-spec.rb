#!/usr/bin/env ruby

def content_must_not_be_empty(results_xml, content_name)
  content_query = "/query-results/list/document/content[@name='#{content_name}']/text()"

  has_content = results_xml.xpath(content_query).any?

  @test_results.add(has_content,
                   "Content exists for: #{content_name}",
                   "No content exists for: #{content_name}")

  text_exists = true
  results_xml.xpath(content_query).each do |r|
    if 1 > r.to_s.size
      @test_results.add(false,
                        "No text exists for: #{content_name}")
    else
      @test_results.add(true,
                        "Found #{r} for: #{content_name}")
    end
  end
end

require 'misc'

@test_results = TestResults.new("Given that Twitter exists and a search for Vivisimo should return something",
                                "When I search for 'vivisimo' in the twitter-search source",
                                "Then I should get back appropriate contents")
# @test_results.need_system_report = false # Uncomment this line to run on OS X

vapi = Vapi.new(TESTENV.velocity, TESTENV.user, TESTENV.password)
results = vapi.query_search(:query => "vivisimo", :sources => "twitter-search")

added_source = results.xpath("//added-source[@name='twitter-search']")

@test_results.add(added_source.first["status"] =='queried',
                 "Twitter source exists and can be queried",
                 "Twitter source is failing somehow - the added source does not have a status of 'queried'. Added-source: #{added_source}")

# Use this to ensure any future changes are testing correctly
# xml_text = <<XML
# <query-results>
#   <list>
#     <document>
#       <content name="title" type="html" action="cluster" weight="1">Text</content>
#       <content name="html-tweet" type="html" action="cluster" weight="1"></content>
#       <content name="published" type="html" action="cluster" weight="1">Today</content>
#       <content name="author-username" type="html" action="cluster" weight="1">Bob</content>
#       <content name="author-display-name" type="html" action="cluster" weight="1">Bobby</content>
#       <content name="author-uri" type="html" action="cluster" weight="1">at twitter</content>
#     </document>
#   </list>
# </query-results>
# XML

# test_blank_xml = Nokogiri::XML(xml_text).root
# content_must_not_be_empty(test_blank_xml, 'html-tweet')

content_must_not_be_empty(results, 'html-tweet')
content_must_not_be_empty(results, 'published')
content_must_not_be_empty(results, 'author-username')
content_must_not_be_empty(results, 'author-display-name')
content_must_not_be_empty(results, 'author-uri')

@test_results.cleanup_and_exit!